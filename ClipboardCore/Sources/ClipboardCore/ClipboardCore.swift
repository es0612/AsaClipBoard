import Foundation
import SwiftData

// モデルクラスを公開
@_exported import struct Foundation.UUID
@_exported import struct Foundation.Data
@_exported import struct Foundation.Date

/// ClipboardCoreパッケージのパブリックインターフェース
public struct ClipboardCore {
    public static let version = "1.0.0"
    
    /// パッケージの初期化
    public static func initialize() {
        // パッケージの初期化処理があれば記述
    }
}