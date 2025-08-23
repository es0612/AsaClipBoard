import Foundation
import KeychainSwift

/// Keychainへの安全なデータ保存を管理するクラス
/// 
/// このクラスは機密データの安全な保存・取得・削除機能を提供します。
/// KeychainSwiftライブラリを使用してmacOSのKeychainサービスにアクセスします。
public class KeychainManager {
    private let keychain: KeychainSwift
    private let keyPrefix: String
    
    /// KeychainManagerを初期化する
    /// - Parameter keyPrefix: Keychainキーのプレフィックス（デフォルト: "AsaClipBoard"）
    public init(keyPrefix: String = "AsaClipBoard") {
        self.keychain = KeychainSwift()
        self.keyPrefix = keyPrefix
        
        // セキュリティ設定
        self.keychain.synchronizable = false // iCloudキーチェーン同期は無効
        self.keychain.accessGroup = nil      // アプリ固有のアクセス
    }
    
    /// データをKeychainに安全に保存する
    /// - Parameters:
    ///   - value: 保存する文字列値
    ///   - key: 保存キー（自動的にプレフィックスが追加される）
    ///   - accessibility: データアクセス権限（デフォルト: .accessibleWhenUnlocked）
    /// - Throws: 保存に失敗した場合のKeychainError
    public func store(_ value: String, forKey key: String, 
                      accessibility: KeychainSwiftAccessOptions = .accessibleWhenUnlocked) throws {
        guard !key.isEmpty else {
            throw KeychainError.storageError("Key cannot be empty")
        }
        
        let prefixedKey = generatePrefixedKey(key)
        let success = keychain.set(value, forKey: prefixedKey, withAccess: accessibility)
        
        if !success {
            throw KeychainError.storageError("Failed to store value for key: \(key)")
        }
    }
    
    /// Keychainからデータを安全に取得する
    /// - Parameter key: 取得キー
    /// - Returns: 保存された文字列値、存在しない場合はnil
    public func retrieve(forKey key: String) -> String? {
        guard !key.isEmpty else { return nil }
        
        let prefixedKey = generatePrefixedKey(key)
        return keychain.get(prefixedKey)
    }
    
    /// Keychainからデータを削除する
    /// - Parameter key: 削除キー
    /// - Returns: 削除が成功した場合はtrue
    @discardableResult
    public func delete(forKey key: String) -> Bool {
        guard !key.isEmpty else { return false }
        
        let prefixedKey = generatePrefixedKey(key)
        return keychain.delete(prefixedKey)
    }
    
    /// 指定したキーのデータが存在するかチェック
    /// - Parameter key: チェックするキー
    /// - Returns: データが存在する場合はtrue
    public func exists(forKey key: String) -> Bool {
        guard !key.isEmpty else { return false }
        
        let prefixedKey = generatePrefixedKey(key)
        return keychain.get(prefixedKey) != nil
    }
    
    /// 複数のキーと値のペアを一括保存する
    /// - Parameter items: 保存するキーと値のディクショナリ
    /// - Throws: いずれかの保存に失敗した場合のKeychainError
    public func storeBatch(_ items: [String: String]) throws {
        for (key, value) in items {
            do {
                try store(value, forKey: key)
            } catch {
                throw KeychainError.storageError("Failed to store batch item for key: \(key) - \(error.localizedDescription)")
            }
        }
    }
    
    /// 複数のキーのデータを一括取得する
    /// - Parameter keys: 取得するキーの配列
    /// - Returns: キーと値のディクショナリ（存在しないキーは含まれない）
    public func retrieveBatch(_ keys: [String]) -> [String: String] {
        var results: [String: String] = [:]
        
        for key in keys {
            if let value = retrieve(forKey: key) {
                results[key] = value
            }
        }
        
        return results
    }
    
    /// 指定したプレフィックスを持つ全てのキーを削除する
    /// - Parameter keyPattern: 削除するキーのパターン（プレフィックス）
    /// - Returns: 削除されたキーの数
    @discardableResult
    public func deleteAll(withPrefix keyPattern: String = "") -> Int {
        let pattern = keyPattern.isEmpty ? keyPrefix : "\(keyPrefix).\(keyPattern)"
        let allKeys = keychain.allKeys.filter { $0.hasPrefix(pattern) }
        
        var deletedCount = 0
        for key in allKeys {
            if keychain.delete(key) {
                deletedCount += 1
            }
        }
        
        return deletedCount
    }
    
    // MARK: - Private Methods
    
    /// プレフィックス付きキーを生成する
    /// - Parameter key: 元のキー
    /// - Returns: プレフィックス付きキー
    private func generatePrefixedKey(_ key: String) -> String {
        return "\(keyPrefix).\(key)"
    }
}

/// Keychain操作関連のエラー
public enum KeychainError: LocalizedError {
    case storageError(String)
    case retrievalError(String)
    
    public var errorDescription: String? {
        switch self {
        case .storageError(let message):
            return "Keychain storage error: \(message)"
        case .retrievalError(let message):
            return "Keychain retrieval error: \(message)"
        }
    }
}