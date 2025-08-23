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
    
    init() {
        // マネージャークラスの初期化
        self.securityManager = SecurityManager()
        self.settingsManager = SettingsManager()
        self.clipboardManager = ClipboardManager()
        
        // パッケージの初期化
        ClipboardSecurity.initialize()
        ClipboardCore.initialize()
        ClipboardUI.initialize()
    }
    
    var body: some Scene {
        MenuBarExtra("AsaClipBoard", systemImage: "doc.on.clipboard") {
            ClipboardHistoryView()
                .environment(clipboardManager)
                .environment(settingsManager)
                .environment(securityManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [ClipboardItemModel.self])
        
        Settings {
            SettingsView()
                .environment(settingsManager)
                .environment(securityManager)
        }
    }
}

// MARK: - Manager Classes

@Observable
class ClipboardManager {
    static let shared = ClipboardManager()
    
    init() {
        // 基本初期化処理
    }
}

@Observable
class SettingsManager {
    static let shared = SettingsManager()
    
    init() {
        // 基本初期化処理  
    }
}