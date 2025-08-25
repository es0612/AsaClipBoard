import Foundation
import Observation

extension Models {
    @Observable
    public class SettingsManager {
    // MARK: - General Settings
    @ObservationIgnored
    public var hotkey: HotkeyConfiguration? {
        didSet {
            save()
        }
    }
    
    public var historyLimit: Int = 100 {
        didSet {
            save()
        }
    }
    
    public var appearance: AppearanceMode = .system {
        didSet {
            save()
        }
    }
    
    public var autoStart: Bool = false {
        didSet {
            save()
        }
    }
    
    public var contentTypes: Set<ContentType> = [.text, .image, .url] {
        didSet {
            save()
        }
    }
    
    // MARK: - Security Settings
    public var privateMode: Bool = false {
        didSet {
            save()
        }
    }
    
    public var autoLockMinutes: Int = 0 {
        didSet {
            save()
        }
    }
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let hotkeyKeyCode = "hotkey_key_code"
        static let hotkeyModifiers = "hotkey_modifiers"
        static let historyLimit = "history_limit"
        static let appearance = "appearance"
        static let autoStart = "auto_start"
        static let contentTypes = "content_types"
        static let privateMode = "private_mode"
        static let autoLockMinutes = "auto_lock_minutes"
    }
    
    public init() {
        loadSettings()
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        // Hotkey configuration
        if defaults.object(forKey: Keys.hotkeyKeyCode) != nil {
            let keyCode = UInt32(defaults.integer(forKey: Keys.hotkeyKeyCode))
            let modifiersRawValue = defaults.integer(forKey: Keys.hotkeyModifiers)
            let modifiers = HotkeyModifiers(rawValue: modifiersRawValue)
            self.hotkey = HotkeyConfiguration(keyCode: keyCode, modifiers: modifiers)
        } else {
            // Default hotkey: Cmd+Shift+V
            self.hotkey = HotkeyConfiguration(keyCode: 9, modifiers: [.command, .shift])
        }
        
        // Other settings
        self.historyLimit = defaults.object(forKey: Keys.historyLimit) as? Int ?? 100
        self.appearance = AppearanceMode(rawValue: defaults.string(forKey: Keys.appearance) ?? "system") ?? .system
        self.autoStart = defaults.bool(forKey: Keys.autoStart)
        self.privateMode = defaults.bool(forKey: Keys.privateMode)
        self.autoLockMinutes = defaults.integer(forKey: Keys.autoLockMinutes)
        
        // Content types
        if let contentTypesData = defaults.data(forKey: Keys.contentTypes),
           let contentTypesArray = try? JSONDecoder().decode([String].self, from: contentTypesData) {
            self.contentTypes = Set(contentTypesArray.compactMap(ContentType.init))
        }
    }
    
    public func save() {
        let defaults = UserDefaults.standard
        
        // Hotkey
        if let hotkey = hotkey {
            defaults.set(Int(hotkey.keyCode), forKey: Keys.hotkeyKeyCode)
            defaults.set(hotkey.modifiers.rawValue, forKey: Keys.hotkeyModifiers)
        }
        
        // Other settings
        defaults.set(historyLimit, forKey: Keys.historyLimit)
        defaults.set(appearance.rawValue, forKey: Keys.appearance)
        defaults.set(autoStart, forKey: Keys.autoStart)
        defaults.set(privateMode, forKey: Keys.privateMode)
        defaults.set(autoLockMinutes, forKey: Keys.autoLockMinutes)
        
        // Content types
        let contentTypesArray = contentTypes.map { $0.rawValue }
        if let contentTypesData = try? JSONEncoder().encode(contentTypesArray) {
            defaults.set(contentTypesData, forKey: Keys.contentTypes)
        }
    }
}

// MARK: - Supporting Types
public struct HotkeyConfiguration: Equatable {
    public let keyCode: UInt32
    public let modifiers: HotkeyModifiers
    
    public init(keyCode: UInt32, modifiers: HotkeyModifiers) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }
    
    /// ホットキーが有効かどうかを確認（モディファイアが必須）
    public var isValid: Bool {
        return !modifiers.isEmpty
    }
    
    /// 表示用の文字列表現を生成
    public var displayString: String {
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
        
        // キーコードを表示可能な文字に変換
        if let keyName = keyCodeToDisplayName(keyCode) {
            components.append(keyName)
        }
        
        return components.joined()
    }
    
    /// キーコードを表示名に変換
    private func keyCodeToDisplayName(_ keyCode: UInt32) -> String? {
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
    
    public static func == (lhs: HotkeyConfiguration, rhs: HotkeyConfiguration) -> Bool {
        return lhs.keyCode == rhs.keyCode && lhs.modifiers == rhs.modifiers
    }
}

public struct HotkeyModifiers: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let command = HotkeyModifiers(rawValue: 1 << 0)
    public static let shift = HotkeyModifiers(rawValue: 1 << 1)
    public static let option = HotkeyModifiers(rawValue: 1 << 2)
    public static let control = HotkeyModifiers(rawValue: 1 << 3)
    
    /// アクティブなモディファイアの数を取得
    public var count: Int {
        var count = 0
        if contains(.command) { count += 1 }
        if contains(.shift) { count += 1 }
        if contains(.option) { count += 1 }
        if contains(.control) { count += 1 }
        return count
    }
}

public enum AppearanceMode: String, CaseIterable, Hashable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .light:
            return "ライト"
        case .dark:
            return "ダーク"
        case .system:
            return "システム"
        }
    }
}

public enum ContentType: String, CaseIterable, Hashable {
    case text = "text"
    case image = "image"
    case url = "url"
    case file = "file"
    
    public var displayName: String {
        switch self {
        case .text:
            return "テキスト"
        case .image:
            return "画像"
        case .url:
            return "URL"
        case .file:
            return "ファイル"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .text:
            return "doc.text"
        case .image:
            return "photo"
        case .url:
            return "link"
        case .file:
            return "doc"
        }
    }
}
}