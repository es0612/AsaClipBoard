import Foundation
import SwiftData
import CloudKit

// Foundation型を公開
@_exported import struct Foundation.UUID
@_exported import struct Foundation.Data
@_exported import struct Foundation.Date

// CloudKit関連型を公開
@_exported import class CloudKit.CKRecord
@_exported import class CloudKit.CKContainer
@_exported import enum CloudKit.CKAccountStatus

/// ClipboardCoreパッケージのパブリックインターフェース
public struct ClipboardCore {
    public static let version = "1.0.0"
    
    /// パッケージの初期化
    public static func initialize() {
        // パッケージの初期化処理があれば記述
    }
}