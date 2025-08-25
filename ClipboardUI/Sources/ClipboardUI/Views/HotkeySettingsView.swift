import SwiftUI
import ClipboardCore

extension Views {
    public struct HotkeySettingsView: View {
        @Bindable var settingsManager: Models.SettingsManager
        @State private var isCapturing = false
        @State private var capturedKeyCode: UInt32?
        @State private var capturedModifiers: Models.HotkeyModifiers = []
        
        public init(settingsManager: Models.SettingsManager) {
            self.settingsManager = settingsManager
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("ホットキー設定")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                GroupBox("ホットキー") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("現在のホットキー:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            if let hotkey = settingsManager.hotkey {
                                Text(hotkey.displayString)
                                    .font(.system(.body, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            } else {
                                Text("設定されていません")
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        
                        HStack {
                            Button(isCapturing ? "キャンセル" : "ホットキーを設定") {
                                toggleCapturing()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(false)
                            
                            if settingsManager.hotkey != nil {
                                Button("リセット") {
                                    resetHotkey()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        
                        if isCapturing {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("新しいホットキーを押してください...")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Text("⌘ Command、⌥ Option、⇧ Shift、⌃ Control キーと組み合わせて使用してください")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if !capturedModifiers.isEmpty {
                                    HStack {
                                        Text("キャプチャ中:")
                                        Text(buildDisplayString(keyCode: capturedKeyCode, modifiers: capturedModifiers))
                                            .font(.system(.body, design: .monospaced))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.1))
                                            .cornerRadius(4)
                                    }
                                    .font(.caption)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
                .groupBoxStyle(.automatic)
                
                Spacer()
            }
            .padding()
            .onAppear {
                setupKeyCapture()
            }
            .onDisappear {
                cleanupKeyCapture()
            }
        }
        
        private func toggleCapturing() {
            isCapturing.toggle()
            if isCapturing {
                capturedKeyCode = nil
                capturedModifiers = []
                startKeyCapture()
            } else {
                stopKeyCapture()
            }
        }
        
        private func resetHotkey() {
            settingsManager.hotkey = Models.HotkeyConfiguration(
                keyCode: 9, // Default: V key
                modifiers: [.command, .shift] // Cmd+Shift+V
            )
        }
        
        private func buildDisplayString(keyCode: UInt32?, modifiers: Models.HotkeyModifiers) -> String {
            var components: [String] = []
            
            if modifiers.contains(.control) {
                components.append("⌃")
            }
            if modifiers.contains(.option) {
                components.append("⌥")
            }
            if modifiers.contains(.shift) {
                components.append("⇧")
            }
            if modifiers.contains(.command) {
                components.append("⌘")
            }
            
            if let keyCode = keyCode {
                components.append(keyCodeToDisplayName(keyCode))
            } else {
                components.append("?")
            }
            
            return components.joined()
        }
        
        private func keyCodeToDisplayName(_ keyCode: UInt32) -> String {
            switch keyCode {
            case 49: return "Space"
            case 36: return "Return"
            case 48: return "Tab"
            case 51: return "Delete"
            case 53: return "Escape"
            case 0...25: // A-Z keys
                let unicodeValue = keyCode + 97 // 'a' = 97
                return String(UnicodeScalar(unicodeValue) ?? UnicodeScalar(97)!)
            case 18...29: // 1-0 keys  
                let number = (keyCode == 29) ? 0 : keyCode - 17
                return String(number)
            default:
                return "Key \(keyCode)"
            }
        }
        
        // MARK: - Key Capture Functions (Placeholder)
        
        private func setupKeyCapture() {
            // macOSのキーイベントキャプチャのセットアップ
            // 実際の実装では NSEvent.addGlobalMonitorForEvents を使用
        }
        
        private func cleanupKeyCapture() {
            // キーイベントキャプチャのクリーンアップ
        }
        
        private func startKeyCapture() {
            // グローバルキーイベントの監視開始
            // 実際の実装では NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .flagsChanged])
        }
        
        private func stopKeyCapture() {
            // キーイベント監視の停止
            isCapturing = false
            
            // キャプチャされた情報から新しいホットキーを作成
            if let keyCode = capturedKeyCode, !capturedModifiers.isEmpty {
                let newHotkey = Models.HotkeyConfiguration(
                    keyCode: keyCode,
                    modifiers: capturedModifiers
                )
                
                if newHotkey.isValid {
                    settingsManager.hotkey = newHotkey
                }
            }
            
            capturedKeyCode = nil
            capturedModifiers = []
        }
    }
}