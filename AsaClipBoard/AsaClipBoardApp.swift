import SwiftUI
import ClipboardUI
import ClipboardCore
import ClipboardSecurity

@main
struct AsaClipBoardApp: App {
    
    init() {
        // パッケージの初期化
        ClipboardSecurity.initialize()
        ClipboardCore.initialize()
        ClipboardUI.initialize()
    }
    
    var body: some Scene {
        MenuBarExtra("AsaClipBoard", systemImage: "doc.on.clipboard") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView()
        }
    }
}