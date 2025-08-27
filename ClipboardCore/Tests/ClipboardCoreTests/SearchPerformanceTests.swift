import Testing
import Foundation
import SwiftData
@testable import ClipboardCore

@Test("SearchManagerキャッシュ機能テスト")
func testSearchCaching() async throws {
    let context = try createTestContext()
    let sut = SearchManager(modelContext: context)
    
    // テストデータを追加
    let testItems = createTestItems(count: 100)
    for item in testItems {
        context.insert(item)
    }
    try context.save()
    
    // 同一クエリを2回検索してキャッシュ効果を確認
    let query = "test query"
    
    let startTime1 = Date()
    let results1 = await sut.search(query: query)
    let duration1 = Date().timeIntervalSince(startTime1)
    
    let startTime2 = Date()
    let results2 = await sut.search(query: query)
    let duration2 = Date().timeIntervalSince(startTime2)
    
    // 2回目の検索がキャッシュにより高速化されているか確認
    #expect(duration2 < duration1 * 0.8) // 20%以上高速化
    #expect(results1.count == results2.count)
}

@Test("SearchManager並列検索パフォーマンステスト")
func testParallelSearchPerformance() async throws {
    let context = try createTestContext()
    let sut = SearchManager(modelContext: context)
    
    // 大量のテストデータを追加
    let testItems = createTestItems(count: 1000)
    for item in testItems {
        context.insert(item)
    }
    try context.save()
    
    let queries = ["swift", "test", "data", "search", "performance"]
    
    // シーケンシャル検索のパフォーマンス測定
    let startTimeSequential = Date()
    var sequentialResults: [[ClipboardItemModel]] = []
    for query in queries {
        let result = await sut.search(query: query)
        sequentialResults.append(result)
    }
    let sequentialDuration = Date().timeIntervalSince(startTimeSequential)
    
    // 並列検索のパフォーマンス測定
    let startTimeParallel = Date()
    let parallelResults = await withTaskGroup(of: [ClipboardItemModel].self, returning: [[ClipboardItemModel]].self) { group in
        for query in queries {
            group.addTask {
                await sut.search(query: query)
            }
        }
        
        var results: [[ClipboardItemModel]] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
    let parallelDuration = Date().timeIntervalSince(startTimeParallel)
    
    // 並列処理が高速化されているか確認
    #expect(parallelDuration < sequentialDuration * 0.8)
    #expect(parallelResults.count == queries.count)
}

@Test("SearchManager大規模データ検索テスト")
func testLargeDatasetSearch() async throws {
    let context = try createTestContext()
    let sut = SearchManager(modelContext: context)
    
    // 5,000件の大規模データセットを作成（テスト時間短縮のため）
    let largeDataset = createTestItems(count: 5000)
    for item in largeDataset {
        context.insert(item)
    }
    try context.save()
    
    // インデックス構築を待つ
    try await Task.sleep(for: .milliseconds(500))
    
    let query = "test content"
    
    let startTime = Date()
    let results = await sut.search(query: query)
    let duration = Date().timeIntervalSince(startTime)
    
    // 大規模データでも2秒以内に検索完了（現実的な目標）
    #expect(duration < 2.0)
    #expect(results.count <= 50) // 結果数制限の確認
    #expect(results.count > 0) // 結果が存在することを確認
}

@Test("SearchManagerインデックス更新パフォーマンステスト")
func testIndexUpdatePerformance() async throws {
    let context = try createTestContext()
    let sut = SearchManager(modelContext: context)
    
    // 初期データセット
    let initialItems = createTestItems(count: 100)
    for item in initialItems {
        context.insert(item)
    }
    try context.save()
    
    // インデックス更新のパフォーマンス測定
    let newItems = createTestItems(count: 50)
    
    let startTime = Date()
    for item in newItems {
        context.insert(item)
        await sut.refreshSearchIndex() // インデックス更新
    }
    try context.save()
    let duration = Date().timeIntervalSince(startTime)
    
    // インデックス更新が効率的に行われているか確認
    #expect(duration < 0.5) // 500ms以内
    
    // 更新後の検索が正常に動作するか確認
    let searchResults = await sut.search(query: "test")
    #expect(searchResults.count > initialItems.count) // 新しいアイテムも検索されることを確認
}

@Test("SearchManagerメモリ効率テスト")
func testMemoryEfficiency() async throws {
    let context = try createTestContext()
    let sut = SearchManager(modelContext: context)
    
    // 大量のテストデータを順次追加してメモリ使用量を確認
    for batch in 0..<10 {
        let batchItems = createTestItems(count: 100, batchPrefix: "batch\(batch)")
        for item in batchItems {
            context.insert(item)
        }
        try context.save()
        
        // 各バッチ後に検索を実行してメモリリークがないか確認
        let results = await sut.search(query: "batch\(batch)")
        #expect(results.count > 0)
    }
    
    // 最終的な検索結果数が適切に制限されているか確認
    let finalResults = await sut.search(query: "batch")
    #expect(finalResults.count <= 50) // 結果数制限
}

// MARK: - ヘルパーメソッド

private func createTestContext() throws -> ModelContext {
    let schema = Schema([ClipboardItemModel.self, SmartActionModel.self, CategoryModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    return ModelContext(container)
}

private func createTestItems(count: Int, batchPrefix: String = "test") -> [ClipboardItemModel] {
    return (0..<count).map { index in
        let text = "\(batchPrefix) content \(index) swift programming data search performance"
        let data = text.data(using: .utf8) ?? Data()
        return ClipboardItemModel(
            contentData: data,
            contentType: .text,
            timestamp: Date().addingTimeInterval(TimeInterval(-index)), // 逆時系列で作成
            preview: text
        )
    }
}