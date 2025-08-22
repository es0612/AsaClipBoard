import Foundation
import KeychainSwift

/// Keychainへの安全なデータ保存を管理するクラス
public class KeychainManager {
    private let keychain: KeychainSwift
    
    public init() {
        self.keychain = KeychainSwift()
        self.keychain.synchronizable = false
        self.keychain.accessGroup = nil
    }
    
    /// データをKeychainに保存する
    /// - Parameters:
    ///   - value: 保存する文字列値
    ///   - key: 保存キー
    /// - Throws: 保存に失敗した場合のエラー
    public func store(_ value: String, forKey key: String) throws {
        let success = keychain.set(value, forKey: key, withAccess: .accessibleWhenUnlocked)
        if !success {
            throw KeychainError.storageError("Failed to store value for key: \(key)")
        }
    }
    
    /// Keychainからデータを取得する
    /// - Parameter key: 取得キー
    /// - Returns: 保存された文字列値、存在しない場合はnil
    public func retrieve(forKey key: String) -> String? {
        return keychain.get(key)
    }
    
    /// Keychainからデータを削除する
    /// - Parameter key: 削除キー
    public func delete(forKey key: String) {
        keychain.delete(key)
    }
    
    /// 指定したキーのデータが存在するかチェック
    /// - Parameter key: チェックするキー
    /// - Returns: データが存在する場合はtrue
    public func exists(forKey key: String) -> Bool {
        return keychain.get(key) != nil
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