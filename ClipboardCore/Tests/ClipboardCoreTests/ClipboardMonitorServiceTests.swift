import Testing
import Foundation
import SwiftData
@testable import ClipboardCore

@Suite("ClipboardMonitorService Tests")
struct ClipboardMonitorServiceTests {
    
    @Test("ClipboardMonitorServiceの基本初期化")
    @MainActor
    func basicInitialization() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        // When
        let sut = ClipboardMonitorService(modelContext: context)
        
        // Then
        #expect(sut.clipboardItems.isEmpty == true)
        #expect(sut.isMonitoring == false)
    }
    
    @Test("クリップボード変更の検出")
    @MainActor
    func clipboardChangeDetection() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context)
        
        // When - テスト用メソッドを使用
        await sut.setTestString("test")
        
        // Then
        #expect(sut.clipboardItems.count == 1)
        #expect(sut.clipboardItems.first?.preview.contains("test") == true)
    }
    
    @Test("重複コンテンツの処理")
    @MainActor
    func duplicateContentHandling() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context)
        
        // When
        await sut.setTestString("duplicate")
        await sut.setTestString("duplicate") // 同じ内容を再度処理
        
        // Then
        #expect(sut.clipboardItems.count == 1, "重複コンテンツは1つのアイテムとして処理される")
    }
    
    @Test("監視の開始と停止")
    @MainActor
    func startAndStopMonitoring() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context)
        
        // When & Then
        sut.startMonitoring()
        #expect(sut.isMonitoring == true)
        
        sut.stopMonitoring()
        #expect(sut.isMonitoring == false)
    }
    
    @Test("最大履歴制限の適用")
    @MainActor
    func historyLimitEnforcement() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context, maxHistorySize: 3)
        
        // When - 制限を超える数のアイテムを追加
        for i in 1...5 {
            await sut.setTestString("item \(i)")
        }
        
        // Then
        #expect(sut.clipboardItems.count == 3, "最大履歴サイズが適用される")
        #expect(sut.clipboardItems.first?.preview.contains("item 5") == true, "最新のアイテムが保持される")
    }
    
    @Test("異なるコンテンツタイプの処理")
    @MainActor
    func differentContentTypes() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context)
        
        // When - 異なるタイプのコンテンツを処理
        await sut.setTestString("https://www.apple.com")
        await sut.setTestString("user@example.com")
        
        // Then
        #expect(sut.clipboardItems.count == 2)
        
        let items = sut.clipboardItems.sorted { $0.timestamp > $1.timestamp }
        #expect(items.first?.contentType == .email)
        #expect(items.last?.contentType == .url)
    }
}