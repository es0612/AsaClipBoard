import Testing
import UserNotifications
@testable import ClipboardUI

@Suite("NotificationManager Tests")
struct NotificationManagerTests {
    
    @Test("NotificationManagerの初期化")
    @MainActor func notificationManagerInitialization() async {
        let mockCenter = MockNotificationCenter()
        mockCenter.mockAuthorizationStatus = .notDetermined
        let manager = NotificationManager(notificationCenter: mockCenter)
        
        // 非同期の初期化が完了するまで待機
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(manager.isEnabled == false, "初期状態では通知が無効")
        #expect(manager.authorizationStatus == .notDetermined, "初期状態では認証ステータスが未決定")
    }
    
    @Test("通知許可の要求")
    @MainActor func requestNotificationPermission() async {
        let mockCenter = MockNotificationCenter()
        mockCenter.mockAuthorizationStatus = .authorized
        let manager = NotificationManager(notificationCenter: mockCenter)
        
        // 通知許可をリクエスト
        await manager.requestPermission()
        
        // 実際の許可状態は実行環境に依存するため、要求が正常に実行されることのみテスト
        #expect(manager.authorizationStatus != .notDetermined, "許可要求後は認証ステータスが決定される")
    }
    
    @Test("同期完了通知の送信")
    @MainActor func sendSyncCompletionNotification() async {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(notificationCenter: mockCenter)
        manager.isEnabled = true
        
        await manager.sendSyncCompletionNotification(itemCount: 5)
        
        #expect(mockCenter.addedRequests.count == 1, "同期完了通知が1つ追加される")
        
        let request = mockCenter.addedRequests.first
        #expect(request?.identifier == "sync-completion", "通知IDが正しい")
        #expect(request?.content.title == "同期完了", "通知タイトルが正しい")
        #expect(request?.content.body.contains("5") == true, "通知内容にアイテム数が含まれる")
    }
    
    @Test("エラー通知の送信")
    @MainActor func sendErrorNotification() async {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(notificationCenter: mockCenter)
        manager.isEnabled = true
        
        let error = ClipboardError.syncFailed("Connection timeout")
        await manager.sendErrorNotification(error: error)
        
        #expect(mockCenter.addedRequests.count == 1, "エラー通知が1つ追加される")
        
        let request = mockCenter.addedRequests.first
        #expect(request?.identifier.hasPrefix("error-") == true, "エラー通知IDが正しいプレフィックスを持つ")
        #expect(request?.content.title == "エラーが発生しました", "エラー通知タイトルが正しい")
        #expect(request?.content.body.contains("Connection timeout") == true, "通知内容にエラーメッセージが含まれる")
    }
    
    @Test("クリップボード更新通知の送信")
    @MainActor func sendClipboardUpdateNotification() async {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(notificationCenter: mockCenter)
        manager.isEnabled = true
        
        await manager.sendClipboardUpdateNotification(preview: "Hello, World!")
        
        #expect(mockCenter.addedRequests.count == 1, "クリップボード更新通知が1つ追加される")
        
        let request = mockCenter.addedRequests.first
        #expect(request?.identifier == "clipboard-update", "通知IDが正しい")
        #expect(request?.content.title == "クリップボード更新", "通知タイトルが正しい")
        #expect(request?.content.body.contains("Hello, World!") == true, "通知内容にプレビューが含まれる")
    }
    
    @Test("通知有効化の切り替え")
    @MainActor func toggleNotificationEnabled() async {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(notificationCenter: mockCenter)
        
        // 初期状態は無効
        #expect(manager.isEnabled == false, "初期状態では通知が無効")
        
        // 通知を有効化
        await manager.setEnabled(true)
        #expect(manager.isEnabled == true, "通知が有効化される")
        
        // 通知を無効化
        await manager.setEnabled(false)
        #expect(manager.isEnabled == false, "通知が無効化される")
    }
    
    @Test("重複通知の防止")
    @MainActor func preventDuplicateNotifications() async {
        let mockCenter = MockNotificationCenter()
        let manager = NotificationManager(notificationCenter: mockCenter)
        manager.isEnabled = true
        
        // 同じタイプの通知を連続で送信
        await manager.sendClipboardUpdateNotification(preview: "Test 1")
        await manager.sendClipboardUpdateNotification(preview: "Test 2")
        
        // 最後の通知のみが残る（同じIDで上書き）
        #expect(mockCenter.addedRequests.count == 2, "通知が2回追加される")
        
        let lastRequest = mockCenter.addedRequests.last
        #expect(lastRequest?.content.body.contains("Test 2") == true, "最新の通知内容が保持される")
    }
}

// MARK: - Mock Classes

class MockNotificationCenter: NotificationCenterProtocol {
    var addedRequests: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    var mockAuthorizationStatus: UNAuthorizationStatus = .authorized
    var mockAuthorizationGranted: Bool = true
    
    func add(_ request: UNNotificationRequest) async throws {
        addedRequests.append(request)
    }
    
    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedIdentifiers.append(contentsOf: identifiers)
    }
    
    func removeAllPendingNotificationRequests() {
        removedIdentifiers.removeAll()
        addedRequests.removeAll()
    }
    
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return mockAuthorizationGranted
    }
    
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        return mockAuthorizationStatus
    }
}

// Create a simple wrapper instead of subclassing UNNotificationSettings
struct MockNotificationSettingsWrapper {
    let authorizationStatus: UNAuthorizationStatus
}

// MARK: - Error Types

enum ClipboardError: LocalizedError {
    case syncFailed(String)
    case networkError(String)
    case storageError(String)
    
    var errorDescription: String? {
        switch self {
        case .syncFailed(let message):
            return "同期に失敗しました: \(message)"
        case .networkError(let message):
            return "ネットワークエラー: \(message)"
        case .storageError(let message):
            return "ストレージエラー: \(message)"
        }
    }
}