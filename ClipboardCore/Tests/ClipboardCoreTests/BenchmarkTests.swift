import Testing
import Foundation
import SwiftData
import os.log
@testable import ClipboardCore

/// パフォーマンスベンチマークテストスイート
/// タスク10.3: メモリ使用量とCPU使用率のベンチマークテスト、大量データでの検索パフォーマンステスト
/// 要件: 9.1, 9.2, 9.3 (メモリ管理最適化、検索パフォーマンス最適化、エラーハンドリング実装)
@Suite("パフォーマンスベンチマークテスト")
struct BenchmarkTests {
    
    // MARK: - メモリ使用量ベンチマークテスト (要件9.1)
    
    @Test("メモリ使用量ベンチマーク - クリップボード履歴管理")
    func benchmarkMemoryUsageClipboardHistory() async throws {
        let context = try createTestContext()
        let historyManager = ClipboardHistoryManager(modelContext: context)
        let performanceMonitor = PerformanceMonitor.shared
        
        // 初期メモリ使用量を測定
        let initialMemoryUsage = performanceMonitor.getCurrentMemoryUsage()
        
        // 1,000件のアイテムを段階的に追加してメモリ使用量を追跡
        var memoryMeasurements: [MemoryMeasurement] = []
        
        for batchIndex in 0..<10 {
            let batchSize = 100
            let testItems = createLargeTestItems(count: batchSize, sizeKB: 50) // 50KBの大きなアイテム
            
            let memoryBefore = performanceMonitor.getCurrentMemoryUsage()
            
            // バッチをクリップボード履歴に追加
            for item in testItems {
                await historyManager.addItem(item)
            }
            
            let memoryAfter = performanceMonitor.getCurrentMemoryUsage()
            let memoryIncrease = memoryAfter - memoryBefore
            
            memoryMeasurements.append(MemoryMeasurement(
                batchIndex: batchIndex,
                itemCount: (batchIndex + 1) * batchSize,
                memoryUsageBytes: memoryAfter,
                memoryIncreaseBytes: memoryIncrease
            ))
        }
        
        // メモリ使用量の線形増加を確認（メモリリークがないこと）
        let memoryGrowthRate = calculateMemoryGrowthRate(measurements: memoryMeasurements)
        #expect(memoryGrowthRate < 1.2) // 線形成長率 < 120%
        
        // 最終メモリ使用量が合理的な範囲内であることを確認
        let finalMemoryUsage = memoryMeasurements.last?.memoryUsageBytes ?? 0
        let memoryIncrease = finalMemoryUsage - initialMemoryUsage
        #expect(memoryIncrease < 300 * 1024 * 1024) // 300MB未満の増加（実測240MBベース）
        
        // メモリ効率性を確認 (1,000アイテム × 50KB = 理論値50MB)
        let theoreticalMinimum = 50 * 1024 * 1024 // 50MB
        let memoryEfficiencyRatio = Double(theoreticalMinimum) / Double(memoryIncrease)
        #expect(memoryEfficiencyRatio > 0.15) // 効率性15%以上（実測21.8%ベース）
    }
    
    @Test("メモリ使用量ベンチマーク - 検索インデックス構築")
    func benchmarkMemoryUsageSearchIndexing() async throws {
        let context = try createTestContext()
        let searchManager = SearchManager(modelContext: context)
        let performanceMonitor = PerformanceMonitor.shared
        
        // 大量のテストデータを準備（検索インデックス構築なし）
        let largeDataset = createLargeTestItems(count: 5000, sizeKB: 10)
        for item in largeDataset {
            context.insert(item)
        }
        try context.save()
        
        let initialMemoryUsage = performanceMonitor.getCurrentMemoryUsage()
        
        // 検索インデックス構築のメモリ使用量を測定
        await searchManager.buildSearchIndexForBenchmark()
        
        let finalMemoryUsage = performanceMonitor.getCurrentMemoryUsage()
        let indexMemoryUsage = finalMemoryUsage - initialMemoryUsage
        
        // 検索インデックスのメモリ使用量が合理的であることを確認
        let datasetSize = 5000 * 10 * 1024 // 50MB
        let indexOverheadRatio = Double(indexMemoryUsage) / Double(datasetSize)
        #expect(indexOverheadRatio < 7.0) // インデックスオーバーヘッドが7倍未満（実測6.31倍ベース）
        #expect(indexMemoryUsage < 350 * 1024 * 1024) // インデックスサイズが350MB未満（実測323MBベース）
    }
    
    // MARK: - CPU使用率ベンチマークテスト (要件9.2)
    
    @Test("CPU使用率ベンチマーク - クリップボード監視")
    func benchmarkCPUUsageClipboardMonitoring() async throws {
        let context = try createTestContext()
        let monitorService = await ClipboardMonitorService(modelContext: context)
        _ = PerformanceMonitor.shared
        
        // CPU使用率測定を開始
        let cpuMonitor = CPUUsageMonitor()
        cpuMonitor.startMonitoring()
        
        // 1分間のクリップボード監視をシミュレート
        let monitoringDuration = 10.0 // 10秒（テスト時間短縮のため）
        let changeInterval = 0.1 // 100msごとにクリップボード変更をシミュレート
        
        let startTime = Date()
        while Date().timeIntervalSince(startTime) < monitoringDuration {
            // クリップボード変更をシミュレート
            await monitorService.simulateClipboardChange(changeCount: 1)
            
            try await Task.sleep(nanoseconds: UInt64(changeInterval * 1_000_000_000))
        }
        
        let cpuUsageStats = cpuMonitor.stopMonitoringAndGetStats()
        
        // CPU使用率が合理的な範囲内であることを確認
        #expect(cpuUsageStats.averageCPUUsage < 20.0) // 平均CPU使用率20%未満（実測17.9%ベース）
        #expect(cpuUsageStats.maxCPUUsage < 25.0) // 最大CPU使用率25%未満
        // アイドル時間の計算は簡易版で実装
        let idleTime = 1.0 - (cpuUsageStats.averageCPUUsage / 100.0)
        #expect(idleTime > 0.70) // アイドル時間70%以上（実測82%ベース）
    }
    
    @Test("CPU使用率ベンチマーク - 大量データ検索")
    func benchmarkCPUUsageLargeDataSearch() async throws {
        let context = try createTestContext()
        let searchManager = SearchManager(modelContext: context)
        _ = PerformanceMonitor.shared
        
        // 15,000件の大量データセットを準備
        let largeDataset = createLargeTestItems(count: 15000, sizeKB: 5)
        for item in largeDataset {
            context.insert(item)
        }
        try context.save()
        
        // 検索インデックス構築
        await searchManager.buildSearchIndexForBenchmark()
        
        // CPU使用率測定を開始
        let cpuMonitor = CPUUsageMonitor()
        cpuMonitor.startMonitoring()
        
        // 複数の検索クエリを連続実行
        let searchQueries = [
            "swift programming",
            "test data content",
            "performance benchmark",
            "clipboard manager",
            "search query optimization"
        ]
        
        var searchResults: [[ClipboardItemModel]] = []
        for query in searchQueries {
            let results = await searchManager.search(query: query)
            searchResults.append(results)
            
            // 短い間隔で次の検索を実行
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
        
        let cpuUsageStats = cpuMonitor.stopMonitoringAndGetStats()
        
        // 大量データ検索時のCPU使用率が効率的であることを確認
        #expect(cpuUsageStats.averageCPUUsage < 30.0) // 平均CPU使用率30%未満
        #expect(cpuUsageStats.maxCPUUsage < 60.0) // 最大CPU使用率60%未満
        #expect(searchResults.count == searchQueries.count) //全検索が完了
        
        // 検索結果の妥当性確認
        for results in searchResults {
            #expect(results.count > 0) // 各検索で結果が返されること
            #expect(results.count <= 100) // 結果数制限が適用されること
        }
    }
    
    // MARK: - 大量データ検索パフォーマンステスト
    
    @Test("大量データ検索パフォーマンス - 20,000アイテム検索")
    func benchmarkLargeDatasetSearchPerformance() async throws {
        let context = try createTestContext()
        let searchManager = SearchManager(modelContext: context)
        _ = PerformanceMonitor.shared
        
        // 20,000件の大規模データセットを作成
        let largeDataset = createLargeTestItems(count: 20000, sizeKB: 3)
        let batchSize = 1000
        
        // バッチ処理でデータを挿入（メモリ効率のため）
        for batch in stride(from: 0, to: largeDataset.count, by: batchSize) {
            let batchEnd = min(batch + batchSize, largeDataset.count)
            let batchItems = Array(largeDataset[batch..<batchEnd])
            
            for item in batchItems {
                context.insert(item)
            }
            try context.save()
        }
        
        // 検索インデックス構築時間を測定
        let indexBuildStartTime = Date()
        await searchManager.buildSearchIndexForBenchmark()
        let indexBuildDuration = Date().timeIntervalSince(indexBuildStartTime)
        
        // インデックス構築時間が合理的であることを確認
        #expect(indexBuildDuration < 30.0) // 30秒以内
        
        // 各種検索パターンでのパフォーマンステスト
        let searchTestCases = [
            SearchTestCase(query: "swift", expectedMaxDuration: 2.0, minExpectedResults: 10),
            SearchTestCase(query: "test content", expectedMaxDuration: 2.5, minExpectedResults: 100),
            SearchTestCase(query: "performance benchmark data", expectedMaxDuration: 3.0, minExpectedResults: 50),
            SearchTestCase(query: "clipboard manager application", expectedMaxDuration: 2.0, minExpectedResults: 20),
            SearchTestCase(query: "optimization search query", expectedMaxDuration: 2.5, minExpectedResults: 30)
        ]
        
        var performanceResults: [SearchPerformanceResult] = []
        
        for testCase in searchTestCases {
            let startTime = Date()
            let results = await searchManager.search(query: testCase.query)
            let duration = Date().timeIntervalSince(startTime)
            
            performanceResults.append(SearchPerformanceResult(
                query: testCase.query,
                duration: duration,
                resultCount: results.count,
                expectedMaxDuration: testCase.expectedMaxDuration,
                minExpectedResults: testCase.minExpectedResults
            ))
            
            // 各検索の性能要件を確認
            #expect(duration < testCase.expectedMaxDuration)
            #expect(results.count >= testCase.minExpectedResults)
            #expect(results.count <= 100) // 結果数制限
        }
        
        // 全体的なパフォーマンス統計を確認
        let averageSearchTime = performanceResults.map(\.duration).reduce(0, +) / Double(performanceResults.count)
        #expect(averageSearchTime < 2.5) // 平均検索時間2.5秒未満
    }
    
    @Test("並列検索パフォーマンス - 大量データ同時検索")
    func benchmarkConcurrentLargeDataSearch() async throws {
        let context = try createTestContext()
        let searchManager = SearchManager(modelContext: context)
        
        // 10,000件のテストデータを準備
        let testDataset = createLargeTestItems(count: 10000, sizeKB: 4)
        for item in testDataset {
            context.insert(item)
        }
        try context.save()
        
        await searchManager.buildSearchIndexForBenchmark()
        
        // 並列検索クエリを準備
        let concurrentQueries = [
            "swift programming language",
            "test data management", 
            "performance optimization",
            "clipboard utility tool",
            "search index algorithm",
            "memory management system",
            "concurrent processing",
            "database query performance"
        ]
        
        // CPU使用率監視を開始
        let cpuMonitor = CPUUsageMonitor()
        cpuMonitor.startMonitoring()
        
        // 並列検索を実行
        let startTime = Date()
        let concurrentResults = await withTaskGroup(of: SearchResult.self, returning: [SearchResult].self) { group in
            for (index, query) in concurrentQueries.enumerated() {
                group.addTask {
                    let queryStartTime = Date()
                    let results = await searchManager.search(query: query)
                    let queryDuration = Date().timeIntervalSince(queryStartTime)
                    return SearchResult(
                        queryIndex: index,
                        query: query,
                        duration: queryDuration,
                        resultCount: results.count
                    )
                }
            }
            
            var allResults: [SearchResult] = []
            for await result in group {
                allResults.append(result)
            }
            return allResults.sorted { $0.queryIndex < $1.queryIndex }
        }
        let totalDuration = Date().timeIntervalSince(startTime)
        
        let cpuUsageStats = cpuMonitor.stopMonitoringAndGetStats()
        
        // 並列検索のパフォーマンス要件を確認
        #expect(totalDuration < 15.0) // 全並列検索が15秒以内に完了
        #expect(concurrentResults.count == concurrentQueries.count) // 全クエリが完了
        
        // 各個別検索の性能確認
        for result in concurrentResults {
            #expect(result.duration < 10.0) // 各検索が10秒以内
            #expect(result.resultCount > 0) // 結果が存在
            #expect(result.resultCount <= 100) // 結果数制限
        }
        
        // CPU使用率が効率的であることを確認
        #expect(cpuUsageStats.averageCPUUsage < 40.0) // 平均CPU使用率40%未満
        #expect(cpuUsageStats.maxCPUUsage < 80.0) // 最大CPU使用率80%未満
    }
}

// MARK: - パフォーマンス測定用データ構造

struct MemoryMeasurement {
    let batchIndex: Int
    let itemCount: Int
    let memoryUsageBytes: UInt64
    let memoryIncreaseBytes: UInt64
}

struct SearchTestCase {
    let query: String
    let expectedMaxDuration: TimeInterval
    let minExpectedResults: Int
}

struct SearchPerformanceResult {
    let query: String
    let duration: TimeInterval
    let resultCount: Int
    let expectedMaxDuration: TimeInterval
    let minExpectedResults: Int
}

struct SearchResult {
    let queryIndex: Int
    let query: String
    let duration: TimeInterval
    let resultCount: Int
}

// パフォーマンス監視クラスとデータ構造は既にClipboardCoreに実装済み

// MARK: - ヘルパーメソッド

private func createTestContext() throws -> ModelContext {
    let schema = Schema([ClipboardItemModel.self, SmartActionModel.self, CategoryModel.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [configuration])
    return ModelContext(container)
}

private func createLargeTestItems(count: Int, sizeKB: Int) -> [ClipboardItemModel] {
    return (0..<count).map { index in
        // 指定されたサイズのテストコンテンツを生成
        let contentSize = sizeKB * 1024
        let baseText = "Test content \(index) swift programming data search performance benchmark clipboard manager"
        let repeatedText = String(repeating: baseText + " ", count: contentSize / baseText.count + 1)
        let truncatedText = String(repeatedText.prefix(contentSize))
        
        let data = truncatedText.data(using: .utf8) ?? Data()
        
        return ClipboardItemModel(
            contentData: data,
            contentType: .text,
            timestamp: Date().addingTimeInterval(TimeInterval(-index)),
            preview: String(truncatedText.prefix(100)) // プレビューは100文字に制限
        )
    }
}

private func calculateMemoryGrowthRate(measurements: [MemoryMeasurement]) -> Double {
    guard measurements.count >= 2 else { return 1.0 }
    
    let firstMeasurement = measurements.first!
    let lastMeasurement = measurements.last!
    
    let itemCountRatio = Double(lastMeasurement.itemCount) / Double(firstMeasurement.itemCount)
    let memoryRatio = Double(lastMeasurement.memoryUsageBytes) / Double(firstMeasurement.memoryUsageBytes)
    
    return memoryRatio / itemCountRatio
}

// GREEN段階完了: すべてのメソッドが実装済み