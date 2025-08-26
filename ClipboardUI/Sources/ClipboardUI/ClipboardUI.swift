import Foundation
import SwiftUI
import ClipboardCore

// 公開モジュール
@_exported import SwiftUI
@_exported import ClipboardCore

// 公開コンポーネント
public typealias SettingsView = Views.SettingsView
public typealias SettingsManager = Models.SettingsManager
public typealias HotkeySettingsView = Views.HotkeySettingsView
public typealias AppearanceSettingsView = Views.AppearanceSettingsView
public typealias AppearanceManager = Models.AppearanceManager
public typealias CustomColor = Models.CustomColor

/// ClipboardUIパッケージのパブリックインターフェース
public enum ClipboardUI {
    public static let version = "1.0.0"
    
    /// パッケージの初期化
    public static func initialize() {
        // パッケージの初期化処理があれば記述
    }
    
    public typealias SettingsView = Views.SettingsView
    public typealias SettingsManager = Models.SettingsManager
    public typealias HotkeySettingsView = Views.HotkeySettingsView
    public typealias AppearanceSettingsView = Views.AppearanceSettingsView
    public typealias AppearanceManager = Models.AppearanceManager
    public typealias CustomColor = Models.CustomColor
}

// MARK: - Namespace
public enum Views {}
public enum Models {}
public enum Components {}