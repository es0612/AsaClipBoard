import Foundation
import CryptoKit

/// データの暗号化・復号化を管理するクラス
public class EncryptionManager {
    private let symmetricKey: SymmetricKey
    
    public init() {
        // 実際のアプリでは、Keychainから取得するか、セキュアに生成する
        self.symmetricKey = SymmetricKey(size: .bits256)
    }
    
    /// データを暗号化する
    /// - Parameter data: 暗号化するデータ
    /// - Returns: 暗号化されたデータ
    /// - Throws: 暗号化に失敗した場合のエラー
    public func encrypt(_ data: Data) async throws -> Data {
        do {
            let encryptedData = try AES.GCM.seal(data, using: symmetricKey)
            return encryptedData.combined!
        } catch {
            throw EncryptionError.encryptionFailed("Failed to encrypt data: \(error.localizedDescription)")
        }
    }
    
    /// データを復号化する
    /// - Parameter encryptedData: 暗号化されたデータ
    /// - Returns: 復号化されたデータ
    /// - Throws: 復号化に失敗した場合のエラー
    public func decrypt(_ encryptedData: Data) async throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            return decryptedData
        } catch {
            throw EncryptionError.decryptionFailed("Failed to decrypt data: \(error.localizedDescription)")
        }
    }
    
    /// データが暗号化されているかチェック
    /// - Parameter data: チェックするデータ
    /// - Returns: 暗号化されている可能性がある場合はtrue
    public func isEncrypted(_ data: Data) -> Bool {
        // AES.GCM.SealedBoxの最小サイズをチェック
        return data.count >= 28 // 16 bytes nonce + 12 bytes tag
    }
}

/// 暗号化関連のエラー
public enum EncryptionError: LocalizedError {
    case encryptionFailed(String)
    case decryptionFailed(String)
    case keyGenerationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .encryptionFailed(let message):
            return "Encryption failed: \(message)"
        case .decryptionFailed(let message):
            return "Decryption failed: \(message)"
        case .keyGenerationFailed(let message):
            return "Key generation failed: \(message)"
        }
    }
}