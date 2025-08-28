import Testing
import SwiftData
import Foundation
@testable import ClipboardSecurity
@testable import ClipboardCore
@testable import ClipboardUI

/// テスト用のコンテンツフィルター
public class TestContentFilter: ContentFilterProtocol {
    public var selectedTypes: [ClipboardContentType] = []
    public init() {}
}

/// 各パッケージ間の連携テストスイート
@Suite("Package Integration Tests")
struct PackageIntegrationTests {
    
    // MARK: - Security -> Core Integration
    
    @Test("SecurityManager と ClipboardHistoryManager の連携")
    func securityCoreIntegration() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let securityManager = SecurityManager()
        let historyManager = ClipboardHistoryManager(modelContext: context, securityManager: securityManager)
        
        let sensitiveData = "password: secret123"
        let normalData = "Hello World"
        
        // When - 機密データの処理
        let sensitiveItem = try await historyManager.addItem(contentData: sensitiveData.data(using: .utf8)!, 
                                                           contentType: .text, 
                                                           preview: sensitiveData)
        
        // Then - 機密データが暗号化されて保存される
        #expect(sensitiveItem.isEncrypted == true, "機密データは暗号化される")
        
        // When - 通常データの処理  
        let normalItem = try await historyManager.addItem(contentData: normalData.data(using: .utf8)!,
                                                         contentType: .text,
                                                         preview: normalData)
        
        // Then - 通常データは暗号化されない
        #expect(normalItem.isEncrypted == false, "通常データは暗号化されない")
    }
    
    @Test("KeychainManager の基本動作")
    func securityComponentsIntegration() async throws {
        // Given
        let keychainManager = KeychainManager()
        
        let testValue = "Test keychain data"
        let testKey = "test_integration_key"
        
        // When - データ保存
        try keychainManager.store(testValue, forKey: testKey)
        
        // Then - データが保存される
        let retrievedValue = keychainManager.retrieve(forKey: testKey)
        #expect(retrievedValue == testValue, "データがKeychainに保存・取得される")
        
        // Cleanup
        keychainManager.delete(forKey: testKey)
    }
    
    // MARK: - Core -> UI Integration
    
    @Test("ClipboardHistoryManager と SettingsManager の連携")
    func coreUIIntegration() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let settingsManager = SettingsManager()
        let historyManager = ClipboardHistoryManager(modelContext: context)
        
        // When - 履歴制限設定の変更
        settingsManager.historyLimit = 5
        
        // 6個のアイテムを追加
        for i in 1...6 {
            let item = ClipboardItemModel(
                contentData: "Item \(i)".data(using: .utf8)!,
                contentType: .text,
                preview: "Item \(i)"
            )
            context.insert(item)
        }
        try context.save()
        
        // When - メモリ制限を適用
        await historyManager.enforceMemoryLimits(maxItems: settingsManager.historyLimit)
        
        // Then - アイテム数が制限内に収まる
        let descriptor = FetchDescriptor<ClipboardItemModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let items = try context.fetch(descriptor)
        #expect(items.count <= settingsManager.historyLimit, "履歴がSettings制限内に収まる")
    }
    
    @Test("SearchManager と ContentFilter の連携") 
    func searchFilterIntegration() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let searchManager = SearchManager(modelContext: context)
        let contentFilter = TestContentFilter()
        
        // テストデータを追加
        let textItem = ClipboardItemModel(contentData: "Hello World".data(using: .utf8)!, 
                                        contentType: .text, preview: "Hello World")
        let imageItem = ClipboardItemModel(contentData: Data(), 
                                         contentType: .image, preview: "Sample Image")
        let urlItem = ClipboardItemModel(contentData: "https://example.com".data(using: .utf8)!,
                                        contentType: .url, preview: "https://example.com")
        
        context.insert(textItem)
        context.insert(imageItem)
        context.insert(urlItem)
        try context.save()
        
        await searchManager.refreshSearchIndex()
        
        // When - フィルタリング付き検索
        contentFilter.selectedTypes = [ClipboardContentType.text, ClipboardContentType.url]
        let filteredResults = await searchManager.searchWithFilter(query: "Hello", filter: contentFilter)
        
        // Then - フィルタ条件に合致するアイテムのみ返される
        #expect(filteredResults.count == 1, "フィルタ条件に合致するアイテムのみ返される")
        #expect(filteredResults.first?.contentType == .text, "テキストタイプのアイテムが返される")
    }
}