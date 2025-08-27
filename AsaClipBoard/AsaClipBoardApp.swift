import SwiftUI
import SwiftData
import Observation
import ClipboardUI
import ClipboardCore
import ClipboardSecurity

@main
struct AsaClipBoardApp: App {
    static let version = "1.0.0"
    
    let clipboardManager: ClipboardManager
    let settingsManager: SettingsManager  
    let securityManager: SecurityManager
    let menuBarExtraManager: MenuBarExtraManager
    let notificationManager: NotificationManager
    
    init() {
        // マネージャークラスの初期化
        self.securityManager = SecurityManager()
        self.settingsManager = SettingsManager()
        self.clipboardManager = ClipboardManager()
        self.menuBarExtraManager = MenuBarExtraManager()
        self.notificationManager = NotificationManager()
        
        // パッケージの初期化
        ClipboardSecurity.initialize()
        ClipboardCore.initialize()
        ClipboardUI.initialize()
        
        // MenuBarExtraManagerのコールバック設定
        setupMenuBarExtraCallbacks()
        
        // 初期データをMenuBarExtraManagerに設定
        clipboardManager.updateMenuBarExtra(with: menuBarExtraManager)
        
        // ClipboardManagerに通知マネージャーを設定
        clipboardManager.setNotificationManager(notificationManager)
    }
    
    var body: some Scene {
        MenuBarExtra("AsaClipBoard", systemImage: "doc.on.clipboard") {
            menuBarExtraManager.makeQuickPreviewView()
                .environment(clipboardManager)
                .environment(settingsManager)
                .environment(securityManager)
                .environment(menuBarExtraManager)
                .environment(notificationManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [ClipboardItemModel.self])
        
        Settings {
            SettingsView()
                .environment(settingsManager)
                .environment(securityManager)
                .environment(notificationManager)
        }
    }
    
    @MainActor
    private func setupMenuBarExtraCallbacks() {
        // ウィンドウ表示のコールバック
        menuBarExtraManager.onShowWindow = {
            // 完全なクリップボード履歴ウィンドウを表示
            // TODO: 実装予定
            print("Show full clipboard history window")
        }
        
        // アイテム選択のコールバック
        menuBarExtraManager.onItemSelected = { [weak clipboardManager] item in
            Task {
                await clipboardManager?.copyToClipboard(item)
            }
        }
    }
}

// MARK: - Manager Classes

@Observable
class ClipboardManager {
    static let shared = ClipboardManager()
    
    var recentItems: [ClipboardItemModel] = []
    private var notificationManager: NotificationManager?
    
    init() {
        // 基本初期化処理
        loadRecentItems()
    }
    
    /// 通知マネージャーを設定
    func setNotificationManager(_ manager: NotificationManager) {
        self.notificationManager = manager
    }
    
    /// クリップボードにアイテムをコピー
    func copyToClipboard(_ item: ClipboardItemModel) async {
        // NSPasteboardにコピー
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item.contentType {
        case .text, .code, .url, .email:
            let string = String(data: item.contentData, encoding: .utf8) ?? ""
            pasteboard.setString(string, forType: .string)
        case .image:
            if let image = NSImage(data: item.contentData) {
                pasteboard.setData(image.tiffRepresentation, forType: .tiff)
            }
        default:
            // その他のタイプの場合はrawデータとして設定
            pasteboard.setData(item.contentData, forType: .string)
        }
        
        print("Copied to clipboard: \(item.preview)")
        
        // クリップボード更新通知を送信
        if let notificationManager = notificationManager {
            await notificationManager.sendClipboardUpdateNotification(preview: item.preview)
        }
    }
    
    /// 最近のアイテムを読み込み
    private func loadRecentItems() {
        // テストデータを追加（実際の実装では SwiftData から読み込み）
        let testData1 = "Hello, World!".data(using: .utf8)!
        let testData2 = "https://www.apple.com".data(using: .utf8)!
        let testData3 = "test@example.com".data(using: .utf8)!
        
        recentItems = [
            ClipboardItemModel(contentData: testData1, contentType: .text, preview: "Hello, World!"),
            ClipboardItemModel(contentData: testData2, contentType: .url, preview: "https://www.apple.com"),
            ClipboardItemModel(contentData: testData3, contentType: .email, preview: "test@example.com")
        ]
    }
    
    /// MenuBarExtraManagerにデータを提供
    @MainActor
    func updateMenuBarExtra(with manager: MenuBarExtraManager) {
        manager.updateQuickPreviewItems(recentItems)
    }
}

@Observable
class SettingsManager {
    static let shared = SettingsManager()
    
    init() {
        // 基本初期化処理  
    }
}