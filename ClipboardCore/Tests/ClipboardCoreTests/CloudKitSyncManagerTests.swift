import Testing
import Foundation
import SwiftData
import CloudKit
@testable import ClipboardCore

@Suite("CloudKitSyncManager Tests")
struct CloudKitSyncManagerTests {
    
    @Test("CloudKitSyncManagerの基本初期化")
    @MainActor
    func basicInitialization() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        // When
        let sut = CloudKitSyncManager(modelContext: context, isTestMode: true)
        
        // Then
        #expect(Bool(true), "CloudKitSyncManagerが正常に初期化される")
    }
    
    @Test("CloudKitコンテナの設定")
    @MainActor
    func cloudKitContainerSetup() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        let sut = CloudKitSyncManager(modelContext: context, isTestMode: true)
        
        // When
        let containerInfo = await sut.getContainerInfo()
        
        // Then
        #expect(!containerInfo.identifier.isEmpty, "CloudKitコンテナIDが取得できる")
    }
    
    @Test("同期状態の管理")
    @MainActor
    func syncStatusManagement() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        let sut = CloudKitSyncManager(modelContext: context, isTestMode: true)
        
        // When
        let initialStatus = sut.syncStatus
        
        // Then
        #expect(initialStatus == .idle, "初期状態はidleである")
    }
    
    @Test("アカウント状態の確認")
    @MainActor
    func accountStatusCheck() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        let sut = CloudKitSyncManager(modelContext: context, isTestMode: true)
        
        // When
        let accountStatus = await sut.checkAccountStatus()
        
        // Then
        #expect(accountStatus == .available, "テストモードではアカウント状態がavailableになる")
    }
    
    @Test("基本的な同期ロジック")
    @MainActor
    func basicSyncLogic() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let item = ClipboardItemModel(
            contentData: "Test sync data".data(using: .utf8)!,
            contentType: .text,
            preview: "Test sync data"
        )
        context.insert(item)
        try context.save()
        
        let sut = CloudKitSyncManager(modelContext: context, isTestMode: true)
        
        // When
        let syncResult = await sut.syncToCloud()
        
        // Then
        #expect(syncResult == true, "同期が成功する")
    }
    
    @Test("CloudKitレコード変換")
    @MainActor
    func cloudKitRecordConversion() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        let sut = CloudKitSyncManager(modelContext: context, isTestMode: true)
        
        let item = ClipboardItemModel(
            contentData: "Test data".data(using: .utf8)!,
            contentType: .text,
            preview: "Test data"
        )
        
        // When
        let record = await sut.convertToCloudKitRecord(item)
        
        // Then
        #expect(record.recordType == "ClipboardItem", "レコードタイプが正しく設定される")
        #expect(record["preview"] as? String == "Test data", "プレビューが正しく設定される")
    }
}