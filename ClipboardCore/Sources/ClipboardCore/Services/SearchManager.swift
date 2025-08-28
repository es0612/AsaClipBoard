import Foundation
import SwiftData
import NaturalLanguage
import Observation

/// コンテンツフィルタープロトコル
public protocol ContentFilterProtocol {
    var selectedTypes: [ClipboardContentType] { get }
}

/// 高速検索とフィルタリング機能を提供するサービス
@Observable
public class SearchManager {
    private let modelContext: ModelContext
    private var searchIndex: [String: Set<UUID>] = [:]
    private let tokenizer = NLTokenizer(unit: .word)
    
    // キャッシュ機能の追加
    private var searchCache: [String: (results: [ClipboardItemModel], timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 30 // 30秒間のキャッシュ
    private let maxCacheSize = 50 // 最大50クエリをキャッシュ
    
    // パフォーマンス監視
    private var indexLastUpdated = Date()
    private let indexUpdateThreshold: TimeInterval = 60 // 60秒ごとにインデックス更新チェック
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        tokenizer.setLanguage(.english) // デフォルト言語を設定
        Task {
            await buildSearchIndex()
        }
    }
    
    /// 検索クエリに基づいてクリップボードアイテムを検索
    public func search(query: String) async -> [ClipboardItemModel] {
        if query.isEmpty {
            return await fetchRecentItems()
        }
        
        // キャッシュチェック
        if let cachedResult = getCachedResult(for: query) {
            return cachedResult
        }
        
        // インデックスの更新が必要かチェック
        await checkAndUpdateIndexIfNeeded()
        
        // 複数の検索戦略を並列実行
        async let exactMatches = searchExact(query: query)
        async let fuzzyMatches = searchFuzzy(query: query)
        async let indexMatches = searchIndex(query: query)
        
        let (exact, fuzzy, indexed) = await (exactMatches, fuzzyMatches, indexMatches)
        
        // 結果をマージして重複を除去
        var allResults: [ClipboardItemModel] = []
        var seenIDs: Set<UUID> = []
        
        // 優先順位: 完全一致 > インデックス検索 > あいまい検索
        for results in [exact, indexed, fuzzy] {
            for item in results {
                if !seenIDs.contains(item.id) {
                    allResults.append(item)
                    seenIDs.insert(item.id)
                }
            }
        }
        
        let finalResults = Array(allResults.prefix(50)) // 最大50件に制限
        
        // 結果をキャッシュに保存
        cacheResult(for: query, results: finalResults)
        
        return finalResults
    }
    
    /// 正規表現パターンによる検索
    public func searchWithRegex(pattern: String) async -> [ClipboardItemModel] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let descriptor = FetchDescriptor<ClipboardItemModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            
            let allItems = try modelContext.fetch(descriptor)
            
            return allItems.filter { item in
                let range = NSRange(location: 0, length: item.preview.count)
                return regex.firstMatch(in: item.preview, range: range) != nil
            }
        } catch {
            print("Regex search failed: \(error)")
            return []
        }
    }
    
    /// コンテンツタイプによる検索
    public func searchByContentType(_ contentType: ClipboardContentType) async -> [ClipboardItemModel] {
        do {
            let descriptor = FetchDescriptor<ClipboardItemModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let allItems = try modelContext.fetch(descriptor)
            
            // SwiftDataのpredicateでEnum比較がサポートされていないため、フィルタリングで対応
            return allItems.filter { $0.contentType == contentType }
        } catch {
            print("Content type search failed: \(error)")
            return []
        }
    }
    
    /// 日付範囲による検索
    public func searchByDateRange(from startDate: Date, to endDate: Date) async -> [ClipboardItemModel] {
        let predicate = #Predicate<ClipboardItemModel> { item in
            item.timestamp >= startDate && item.timestamp <= endDate
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Date range search failed: \(error)")
            return []
        }
    }
    
    /// フィルター付き検索
    public func searchWithFilter(query: String, filter: ContentFilterProtocol) async -> [ClipboardItemModel] {
        let searchResults = await search(query: query)
        
        // フィルターの条件でフィルタリング
        return searchResults.filter { item in
            if filter.selectedTypes.isEmpty {
                return true // フィルターが指定されていない場合は全て表示
            }
            return filter.selectedTypes.contains(item.contentType)
        }
    }
    
    // MARK: - Private Methods
    
    /// 検索インデックスを構築
    private func buildSearchIndex() async {
        do {
            let descriptor = FetchDescriptor<ClipboardItemModel>()
            let allItems = try modelContext.fetch(descriptor)
            
            // インデックスをクリア
            searchIndex.removeAll()
            
            // 各アイテムのコンテンツをトークン化してインデックスに追加
            for item in allItems {
                tokenizer.string = item.preview
                tokenizer.enumerateTokens(in: item.preview.startIndex..<item.preview.endIndex) { range, _ in
                    let word = String(item.preview[range]).lowercased()
                    if word.count > 2 { // 3文字以上の単語のみインデックス化
                        if searchIndex[word] == nil {
                            searchIndex[word] = Set<UUID>()
                        }
                        searchIndex[word]?.insert(item.id)
                    }
                    return true
                }
            }
        } catch {
            print("Failed to build search index: \(error)")
        }
    }
    
    /// 最近のアイテムを取得
    private func fetchRecentItems() async -> [ClipboardItemModel] {
        var descriptor = FetchDescriptor<ClipboardItemModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 20
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch recent items: \(error)")
            return []
        }
    }
    
    /// 完全一致検索
    private func searchExact(query: String) async -> [ClipboardItemModel] {
        let predicate = #Predicate<ClipboardItemModel> { item in
            item.preview.localizedStandardContains(query)
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Exact search failed: \(error)")
            return []
        }
    }
    
    /// インデックスベース検索
    private func searchIndex(query: String) async -> [ClipboardItemModel] {
        let queryWords = query.lowercased().components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count > 2 }
        
        guard !queryWords.isEmpty else { return [] }
        
        var matchingIds: Set<UUID> = Set<UUID>()
        var isFirst = true
        
        // 全ての単語を含むアイテムを見つける（AND検索）
        for word in queryWords {
            if let wordIds = searchIndex[word] {
                if isFirst {
                    matchingIds = wordIds
                    isFirst = false
                } else {
                    matchingIds = matchingIds.intersection(wordIds)
                }
            } else {
                return [] // 一つでも見つからない単語があれば空を返す
            }
        }
        
        // IDからアイテムを取得
        do {
            let descriptor = FetchDescriptor<ClipboardItemModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let allItems = try modelContext.fetch(descriptor)
            
            return allItems.filter { matchingIds.contains($0.id) }
        } catch {
            print("Index search failed: \(error)")
            return []
        }
    }
    
    /// あいまい検索（NaturalLanguageフレームワーク使用）
    private func searchFuzzy(query: String) async -> [ClipboardItemModel] {
        do {
            let descriptor = FetchDescriptor<ClipboardItemModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            let allItems = try modelContext.fetch(descriptor)
            
            var scoredItems: [(ClipboardItemModel, Double)] = []
            
            // 単語レベルでの類似度スコアリング
            for item in allItems {
                let similarity = calculateSimilarity(query: query, text: item.preview)
                if similarity > 0.3 { // 類似度30%以上のもののみ
                    scoredItems.append((item, similarity))
                }
            }
            
            // スコアの高い順にソート
            scoredItems.sort { $0.1 > $1.1 }
            
            return scoredItems.map { $0.0 }
        } catch {
            print("Fuzzy search failed: \(error)")
            return []
        }
    }
    
    /// テキスト間の類似度を計算
    private func calculateSimilarity(query: String, text: String) -> Double {
        let queryWords = Set(query.lowercased().components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters)))
        let textWords = Set(text.lowercased().components(separatedBy: .whitespacesAndNewlines.union(.punctuationCharacters)))
        
        let intersection = queryWords.intersection(textWords)
        let union = queryWords.union(textWords)
        
        guard !union.isEmpty else { return 0.0 }
        
        return Double(intersection.count) / Double(union.count)
    }
    
    // MARK: - キャッシュ管理
    
    /// キャッシュから結果を取得
    private func getCachedResult(for query: String) -> [ClipboardItemModel]? {
        guard let cached = searchCache[query] else { return nil }
        
        // キャッシュの有効期限をチェック
        if Date().timeIntervalSince(cached.timestamp) > cacheTimeout {
            searchCache.removeValue(forKey: query)
            return nil
        }
        
        return cached.results
    }
    
    /// 結果をキャッシュに保存
    private func cacheResult(for query: String, results: [ClipboardItemModel]) {
        // キャッシュサイズ制限チェック
        if searchCache.count >= maxCacheSize {
            // 最も古いエントリを削除
            if let oldestKey = searchCache.min(by: { $0.value.timestamp < $1.value.timestamp })?.key {
                searchCache.removeValue(forKey: oldestKey)
            }
        }
        
        searchCache[query] = (results: results, timestamp: Date())
    }
    
    /// キャッシュをクリア
    public func clearCache() {
        searchCache.removeAll()
    }
    
    // MARK: - インデックス管理の改善
    
    /// インデックスの更新が必要かチェックして、必要に応じて更新
    private func checkAndUpdateIndexIfNeeded() async {
        let now = Date()
        if now.timeIntervalSince(indexLastUpdated) > indexUpdateThreshold {
            await buildSearchIndex()
            indexLastUpdated = now
        }
    }
    
    /// インデックスを強制更新（テスト用）
    public func refreshSearchIndex() async {
        await buildSearchIndex()
        indexLastUpdated = Date()
        clearCache() // インデックス更新時はキャッシュもクリア
    }
    
    /// インデックス統計情報を取得（デバッグ用）
    public func getIndexStatistics() -> (totalWords: Int, totalEntries: Int) {
        let totalWords = searchIndex.count
        let totalEntries = searchIndex.values.reduce(0) { $0 + $1.count }
        return (totalWords: totalWords, totalEntries: totalEntries)
    }
}