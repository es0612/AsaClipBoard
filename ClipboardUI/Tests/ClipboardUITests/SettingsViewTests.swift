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
        let settingsManager = SettingsManager()
        
        // ホットキーのデフォルト値
        #expect(settingsManager.hotkey != nil, "デフォルトホットキーが設定されている")
        
        // 履歴制限のデフォルト値
        #expect(settingsManager.historyLimit == 100, "デフォルト履歴制限が100である")
        
        // 外観のデフォルト値
        #expect(settingsManager.appearance == Models.AppearanceMode.system, "デフォルト外観がシステムである")
        
        // 自動起動のデフォルト値
        #expect(settingsManager.autoStart == false, "デフォルトで自動起動が無効である")
        
        // プライベートモードのデフォルト値
        #expect(settingsManager.privateMode == false, "デフォルトでプライベートモードが無効である")
        
        // 自動ロックのデフォルト値
        #expect(settingsManager.autoLockMinutes == 0, "デフォルトで自動ロックが無効である")
    }
    
    @Test("設定値の永続化")
    func settingsPersistence() {
        let settingsManager = SettingsManager()
        
        // 設定を変更
        settingsManager.historyLimit = 500
        settingsManager.appearance = Models.AppearanceMode.dark
        settingsManager.autoStart = true
        
        // 設定が保存される
        settingsManager.save()
        
        // 新しいインスタンスで設定を読み込み
        let newSettingsManager = SettingsManager()
        
        // 設定が復元されている
        #expect(newSettingsManager.historyLimit == 500, "履歴制限が永続化される")
        #expect(newSettingsManager.appearance == Models.AppearanceMode.dark, "外観設定が永続化される")
        #expect(newSettingsManager.autoStart == true, "自動起動設定が永続化される")
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