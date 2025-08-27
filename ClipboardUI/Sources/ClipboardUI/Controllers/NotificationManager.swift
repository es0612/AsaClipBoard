import SwiftUI
import UserNotifications
import Observation

// MARK: - Protocol for Testability
public protocol NotificationCenterProtocol {
    func add(_ request: UNNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeAllPendingNotificationRequests()
    func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
    func getAuthorizationStatus() async -> UNAuthorizationStatus
}

// MARK: - UNUserNotificationCenter Extension
extension UNUserNotificationCenter: NotificationCenterProtocol {
    public func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            self.requestAuthorization(options: options) { granted, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationSettings()
        return settings.authorizationStatus
    }
}

// MARK: - NotificationManager
extension Controllers {
    @MainActor
    @Observable
    public class NotificationManager: @unchecked Sendable {
    
    // MARK: - Public Properties
    public var isEnabled: Bool = false
    public var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Internal Properties for Testing
    var notificationCenter: NotificationCenterProtocol
    
    // MARK: - Private Properties
    private var lastNotificationIds: Set<String> = []
    
    // MARK: - Initialization
    public init(notificationCenter: NotificationCenterProtocol? = nil) {
        self.notificationCenter = notificationCenter ?? UNUserNotificationCenter.current()
        
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// 通知許可を要求
    public func requestPermission() async {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            
            if granted {
                isEnabled = true
            }
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    /// 通知の有効/無効を設定
    public func setEnabled(_ enabled: Bool) async {
        if enabled && authorizationStatus == .notDetermined {
            await requestPermission()
        } else {
            isEnabled = enabled
        }
    }
    
    /// 同期完了通知を送信
    public func sendSyncCompletionNotification(itemCount: Int) async {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "同期完了"
        content.body = "クリップボード履歴の同期が完了しました。\(itemCount)個のアイテムを同期しました。"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "sync-completion",
            content: content,
            trigger: nil
        )
        
        await sendNotification(request: request)
    }
    
    /// エラー通知を送信
    public func sendErrorNotification(error: Error) async {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "エラーが発生しました"
        content.body = error.localizedDescription
        content.sound = .default
        
        let identifier = "error-\(UUID().uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        
        await sendNotification(request: request)
    }
    
    /// クリップボード更新通知を送信
    public func sendClipboardUpdateNotification(preview: String) async {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "クリップボード更新"
        content.body = "新しいアイテムがコピーされました: \(preview)"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "clipboard-update",
            content: content,
            trigger: nil
        )
        
        await sendNotification(request: request)
    }
    
    // MARK: - Private Methods
    
    /// 認証ステータスを更新
    private func updateAuthorizationStatus() async {
        authorizationStatus = await notificationCenter.getAuthorizationStatus()
        
        if authorizationStatus == .authorized {
            isEnabled = true
        } else if authorizationStatus == .denied {
            isEnabled = false
        }
    }
    
    /// 通知を送信
    private func sendNotification(request: UNNotificationRequest) async {
        do {
            try await notificationCenter.add(request)
            lastNotificationIds.insert(request.identifier)
        } catch {
            print("Failed to send notification: \(error)")
        }
    }
    
    /// 保留中の通知をクリア
    public func clearPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        lastNotificationIds.removeAll()
    }
    
    /// 特定の通知をクリア
    public func clearNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        lastNotificationIds.remove(identifier)
    }
    
    }
}