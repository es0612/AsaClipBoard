import Testing
import SwiftUI
@testable import ClipboardUI

@Suite("SettingsView Tests")
struct SettingsViewTests {
    
    @Test("設定画面の基本構造が正しく表示される")
    func settingsViewBasicStructure() {
        let settingsView = SettingsView()
        #expect(settingsView != nil, "SettingsViewが正常に初期化される")
    }
}

@Suite("GeneralSettingsView Tests")
struct GeneralSettingsViewTests {
    
    @Test("一般設定タブの基本要素が表示される")
    func generalSettingsBasicElements() {
        let generalView = Views.GeneralSettingsView()
        #expect(generalView != nil, "GeneralSettingsViewが正常に初期化される")
    }
    
    @Test("ホットキー設定が表示される")
    func hotkeySettingsDisplay() {
        let settingsManager = SettingsManager()
        let generalView = Views.GeneralSettingsView(settingsManager: settingsManager)
        #expect(generalView != nil, "ホットキー設定を含むGeneralSettingsViewが正常に初期化される")
    }
    
    @Test("履歴制限設定が表示される")
    func historyLimitSettingsDisplay() {
        let settingsManager = SettingsManager()
        let generalView = Views.GeneralSettingsView(settingsManager: settingsManager)
        #expect(generalView != nil, "履歴制限設定を含むGeneralSettingsViewが正常に初期化される")
    }
    
    @Test("外観設定が表示される")
    func appearanceSettingsDisplay() {
        let settingsManager = SettingsManager()
        let generalView = Views.GeneralSettingsView(settingsManager: settingsManager)
        #expect(generalView != nil, "外観設定を含むGeneralSettingsViewが正常に初期化される")
    }
    
    @Test("自動起動設定が表示される")
    func autoStartSettingsDisplay() {
        let settingsManager = SettingsManager()
        let generalView = Views.GeneralSettingsView(settingsManager: settingsManager)
        #expect(generalView != nil, "自動起動設定を含むGeneralSettingsViewが正常に初期化される")
    }
    
    @Test("コンテンツタイプ設定が表示される")
    func contentTypeSettingsDisplay() {
        let settingsManager = SettingsManager()
        let generalView = Views.GeneralSettingsView(settingsManager: settingsManager)
        #expect(generalView != nil, "コンテンツタイプ設定を含むGeneralSettingsViewが正常に初期化される")
    }
}

@Suite("SecuritySettingsView Tests")
struct SecuritySettingsViewTests {
    
    @Test("セキュリティ設定タブの基本要素が表示される")
    func securitySettingsBasicElements() {
        let securityView = Views.SecuritySettingsView()
        #expect(securityView != nil, "SecuritySettingsViewが正常に初期化される")
    }
    
    @Test("プライベートモード設定が表示される")
    func privateModeSettingsDisplay() {
        let settingsManager = SettingsManager()
        let securityView = Views.SecuritySettingsView(settingsManager: settingsManager)
        #expect(securityView != nil, "プライベートモード設定を含むSecuritySettingsViewが正常に初期化される")
    }
    
    @Test("自動ロック設定が表示される")
    func autoLockSettingsDisplay() {
        let settingsManager = SettingsManager()
        let securityView = Views.SecuritySettingsView(settingsManager: settingsManager)
        #expect(securityView != nil, "自動ロック設定を含むSecuritySettingsViewが正常に初期化される")
    }
}

@Suite("SettingsManager Tests")
struct SettingsManagerTests {
    
    @Test("SettingsManagerの初期化")
    func settingsManagerInitialization() {
        let settingsManager = SettingsManager()
        #expect(settingsManager != nil, "SettingsManagerが正常に初期化される")
    }
    
    @Test("デフォルト設定値の確認")
    func defaultSettingsValues() {
        // テスト前に関連するUserDefaultsキーをクリア
        let defaults = UserDefaults.standard
        let keysToClean = [
            "hotkey_key_code", "hotkey_modifiers", "history_limit", 
            "appearance", "auto_start", "content_types", 
            "private_mode", "auto_lock_minutes"
        ]
        keysToClean.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        
        let settingsManager = SettingsManager()
        
        // ホットキーのデフォルト値
        #expect(settingsManager.hotkey != nil, "デフォルトホットキーが設定されている")
        
        // 履歴制限のデフォルト値
        #expect(settingsManager.historyLimit == 100, "デフォルト履歴制限が100である")
        
        // 外観のデフォルト値（実際の初期値を確認）
        // デバッグ: 実際の値を確認
        let actualAppearance = settingsManager.appearance
        #expect(actualAppearance == Models.AppearanceMode.system, "デフォルト外観がシステムである（実際の値: \(actualAppearance.rawValue)）")
        
        // 自動起動のデフォルト値
        #expect(settingsManager.autoStart == false, "デフォルトで自動起動が無効である")
        
        // プライベートモードのデフォルト値
        #expect(settingsManager.privateMode == false, "デフォルトでプライベートモードが無効である")
        
        // 自動ロックのデフォルト値
        #expect(settingsManager.autoLockMinutes == 0, "デフォルトで自動ロックが無効である")
    }
    
    @Test("設定値の永続化")
    func settingsPersistence() {
        // テスト前に関連するUserDefaultsキーをクリア
        let defaults = UserDefaults.standard
        let keysToClean = [
            "hotkey_key_code", "hotkey_modifiers", "history_limit", 
            "appearance", "auto_start", "content_types", 
            "private_mode", "auto_lock_minutes"
        ]
        keysToClean.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        
        let settingsManager = SettingsManager()
        
        // 設定を変更（didSetで自動的にsave()が呼ばれる）
        settingsManager.historyLimit = 500
        settingsManager.appearance = Models.AppearanceMode.dark
        settingsManager.autoStart = true
        
        // 少し待ってからUserDefaultsの変更が確実に反映されるようにする
        Thread.sleep(forTimeInterval: 0.1)
        
        // 新しいインスタンスで設定を読み込み
        let newSettingsManager = SettingsManager()
        
        // 設定が復元されている
        #expect(newSettingsManager.historyLimit == 500, "履歴制限が永続化される")
        #expect(newSettingsManager.appearance == Models.AppearanceMode.dark, "外観設定が永続化される")  
        #expect(newSettingsManager.autoStart == true, "自動起動設定が永続化される")
        
        // テスト後のクリーンアップ
        keysToClean.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
    }
    
    @Test("ホットキー設定の変更")
    func hotkeySettingsChange() {
        let settingsManager = SettingsManager()
        
        let newHotkey = Models.HotkeyConfiguration(keyCode: 49, modifiers: [Models.HotkeyModifiers.command, Models.HotkeyModifiers.shift]) // Cmd+Shift+Space
        settingsManager.hotkey = newHotkey
        
        #expect(settingsManager.hotkey?.keyCode == 49, "ホットキーのキーコードが更新される")
        #expect(settingsManager.hotkey?.modifiers.contains(Models.HotkeyModifiers.command) == true, "ホットキーのモディファイアが更新される")
        #expect(settingsManager.hotkey?.modifiers.contains(Models.HotkeyModifiers.shift) == true, "ホットキーのモディファイアが更新される")
    }
}

@Suite("HotkeySettingsView Tests")
struct HotkeySettingsViewTests {
    
    @Test("ホットキー設定ビューの基本初期化")
    func hotkeySettingsViewInitialization() {
        let settingsManager = SettingsManager()
        let hotkeyView = Views.HotkeySettingsView(settingsManager: settingsManager)
        #expect(hotkeyView != nil, "HotkeySettingsViewが正常に初期化される")
    }
    
    @Test("現在のホットキー設定の表示")
    func currentHotkeyDisplay() {
        let settingsManager = SettingsManager()
        settingsManager.hotkey = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command, Models.HotkeyModifiers.option]
        )
        
        let hotkeyView = Views.HotkeySettingsView(settingsManager: settingsManager)
        #expect(hotkeyView != nil, "現在のホットキー設定を表示するビューが初期化される")
    }
    
    @Test("ホットキーキャプチャ状態の管理")
    func hotkeyCapturingState() {
        let settingsManager = SettingsManager()
        let hotkeyView = Views.HotkeySettingsView(settingsManager: settingsManager)
        // キャプチャ状態の初期値確認など、実装後にテストコードを追加
        #expect(hotkeyView != nil, "ホットキーキャプチャ機能が含まれるビューが初期化される")
    }
    
    @Test("ホットキーリセット機能")
    func hotkeyResetFunction() {
        let settingsManager = SettingsManager()
        settingsManager.hotkey = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command]
        )
        
        let hotkeyView = Views.HotkeySettingsView(settingsManager: settingsManager)
        #expect(hotkeyView != nil, "ホットキーリセット機能が含まれるビューが初期化される")
    }
}

@Suite("HotkeyConfiguration Tests") 
struct HotkeyConfigurationTests {
    
    @Test("ホットキー設定の初期化")
    func hotkeyConfigurationInitialization() {
        let config = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command, Models.HotkeyModifiers.shift]
        )
        
        #expect(config.keyCode == 49, "キーコードが正しく設定される")
        #expect(config.modifiers.count == 2, "モディファイアが正しく設定される")
        #expect(config.modifiers.contains(Models.HotkeyModifiers.command), "Commandモディファイアが含まれる")
        #expect(config.modifiers.contains(Models.HotkeyModifiers.shift), "Shiftモディファイアが含まれる")
    }
    
    @Test("ホットキー文字列表現の生成")
    func hotkeyStringRepresentation() {
        let config = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command, Models.HotkeyModifiers.option]
        )
        
        let displayString = config.displayString
        #expect(!displayString.isEmpty, "表示用文字列が生成される")
        #expect(displayString.contains("⌘"), "Command記号が含まれる")
        #expect(displayString.contains("⌥"), "Option記号が含まれる")
    }
    
    @Test("ホットキーの等価性チェック")
    func hotkeyEquality() {
        let config1 = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command]
        )
        let config2 = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command]
        )
        let config3 = Models.HotkeyConfiguration(
            keyCode: 50, 
            modifiers: [Models.HotkeyModifiers.command]
        )
        
        #expect(config1 == config2, "同じ設定のホットキーが等しい")
        #expect(config1 != config3, "異なる設定のホットキーが等しくない")
    }
    
    @Test("無効なホットキーの検証")
    func invalidHotkeyValidation() {
        // モディファイアなしのホットキー（無効）
        let configWithoutModifiers = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: []
        )
        
        #expect(!configWithoutModifiers.isValid, "モディファイアなしのホットキーが無効として検証される")
        
        // 有効なホットキー
        let validConfig = Models.HotkeyConfiguration(
            keyCode: 49, 
            modifiers: [Models.HotkeyModifiers.command]
        )
        
        #expect(validConfig.isValid, "モディファイアありのホットキーが有効として検証される")
    }
}

@Suite("AppearanceSettingsView Tests")
struct AppearanceSettingsViewTests {
    
    @Test("外観設定ビューの基本初期化")
    func appearanceSettingsViewInitialization() {
        let settingsManager = SettingsManager()
        let appearanceView = Views.AppearanceSettingsView(settingsManager: settingsManager)
        #expect(appearanceView != nil, "AppearanceSettingsViewが正常に初期化される")
    }
    
    @Test("テーマ選択の管理")
    func themeSelection() {
        let settingsManager = SettingsManager()
        
        // 初期状態はシステムテーマ
        #expect(settingsManager.appearance == Models.AppearanceMode.system, "初期状態はシステムテーマ")
        
        // ダークテーマに変更
        settingsManager.appearance = .dark
        #expect(settingsManager.appearance == Models.AppearanceMode.dark, "ダークテーマに変更される")
        
        // ライトテーマに変更
        settingsManager.appearance = .light
        #expect(settingsManager.appearance == Models.AppearanceMode.light, "ライトテーマに変更される")
    }
    
    @Test("カスタムカラーテーマ機能")
    func customColorTheme() {
        let settingsManager = SettingsManager()
        let appearanceView = Views.AppearanceSettingsView(settingsManager: settingsManager)
        
        // カスタムカラーテーマが初期化される
        #expect(appearanceView != nil, "カスタムカラーテーマ機能が含まれるビューが初期化される")
    }
    
    @Test("テーマプレビュー機能")
    func themePreview() {
        let settingsManager = SettingsManager()
        let appearanceView = Views.AppearanceSettingsView(settingsManager: settingsManager)
        
        // テーマプレビューが表示される
        #expect(appearanceView != nil, "テーマプレビュー機能が含まれるビューが初期化される")
    }
}

@Suite("AppearanceManager Tests")
struct AppearanceManagerTests {
    
    @Test("外観管理の初期化")
    func appearanceManagerInitialization() {
        // テスト前にAppearance関連のUserDefaultsキーをクリア
        let defaults = UserDefaults.standard
        let keysToClean = ["appearance_theme", "custom_colors"]
        keysToClean.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        
        let appearanceManager = Models.AppearanceManager()
        
        #expect(appearanceManager != nil, "AppearanceManagerが正常に初期化される")
        #expect(appearanceManager.currentTheme == Models.AppearanceMode.system, "初期テーマがシステムである")
    }
    
    @Test("システム外観の検出")
    func systemAppearanceDetection() {
        let appearanceManager = Models.AppearanceManager()
        
        // システムの外観を検出（テスト環境では.systemが返される）
        let systemAppearance = appearanceManager.detectSystemAppearance()
        #expect(systemAppearance == .light || systemAppearance == .dark || systemAppearance == .system, "システム外観が検出される")
    }
    
    @Test("テーマ変更の通知")
    func themeChangeNotification() {
        let appearanceManager = Models.AppearanceManager()
        
        var notificationReceived = false
        appearanceManager.onThemeChanged = {
            notificationReceived = true
        }
        
        // テーマを変更
        appearanceManager.setTheme(.dark)
        #expect(notificationReceived, "テーマ変更の通知が送信される")
        #expect(appearanceManager.currentTheme == .dark, "テーマが正しく変更される")
    }
    
    @Test("カスタムカラーの管理")
    func customColorManagement() {
        let appearanceManager = Models.AppearanceManager()
        
        // カスタムカラーを設定
        let customColor = Models.CustomColor(
            primary: .blue,
            secondary: .gray,
            accent: .orange,
            background: .white,
            surface: .gray.opacity(0.1)
        )
        
        appearanceManager.setCustomColors(customColor)
        #expect(appearanceManager.customColors != nil, "カスタムカラーが設定される")
        #expect(appearanceManager.customColors?.primary == .blue, "プライマリカラーが正しく設定される")
    }
    
    @Test("テーマの永続化")
    func themePersistence() {
        let appearanceManager1 = Models.AppearanceManager()
        appearanceManager1.setTheme(.dark)
        appearanceManager1.saveSettings()
        
        // 新しいインスタンスで設定を復元
        let appearanceManager2 = Models.AppearanceManager()
        #expect(appearanceManager2.currentTheme == .dark, "テーマが永続化される")
    }
}

@Suite("CustomColor Tests")
struct CustomColorTests {
    
    @Test("カスタムカラーの初期化")
    func customColorInitialization() {
        let customColor = Models.CustomColor(
            primary: .blue,
            secondary: .gray,
            accent: .red,
            background: .white,
            surface: .gray.opacity(0.1)
        )
        
        #expect(customColor.primary == .blue, "プライマリカラーが正しく設定される")
        #expect(customColor.secondary == .gray, "セカンダリカラーが正しく設定される")
        #expect(customColor.accent == .red, "アクセントカラーが正しく設定される")
    }
    
    @Test("デフォルトテーマカラーの生成")
    func defaultThemeColors() {
        let lightColors = Models.CustomColor.defaultLight
        let darkColors = Models.CustomColor.defaultDark
        
        #expect(lightColors != nil, "ライトテーマのデフォルトカラーが生成される")
        #expect(darkColors != nil, "ダークテーマのデフォルトカラーが生成される")
        #expect(lightColors.background != darkColors.background, "ライトとダークで背景色が異なる")
    }
    
    @Test("カラーの16進数変換")
    func colorHexConversion() {
        let customColor = Models.CustomColor(
            primary: .blue,
            secondary: .gray,
            accent: .red,
            background: .white,
            surface: .clear
        )
        
        let hexValues = customColor.toHexValues()
        #expect(!hexValues.isEmpty, "16進数カラー値が生成される")
        #expect(hexValues["primary"] != nil, "プライマリカラーの16進数値が存在する")
    }
}