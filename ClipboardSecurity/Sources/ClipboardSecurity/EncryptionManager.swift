import Foundation
import CryptoKit

/// データの暗号化・復号化を管理するクラス
/// 
/// このクラスはAES-GCMを使用したセキュアなデータ暗号化機能を提供します。
/// 各EncryptionManagerインスタンスは独自の256ビットキーを持ち、
/// データの機密性と完全性を保護します。
public class EncryptionManager {
    private let symmetricKey: SymmetricKey
    private let keychainManager: KeychainManager?
    
    /// 暗号化設定
    public struct EncryptionConfig {
        public let keySize: SymmetricKeySize
        public let useKeychain: Bool
        public let keychainKeyId: String
        
        public init(keySize: SymmetricKeySize = .bits256, 
                   useKeychain: Bool = false,
                   keychainKeyId: String = "EncryptionManager.Key") {
            self.keySize = keySize
            self.useKeychain = useKeychain
            self.keychainKeyId = keychainKeyId
        }
    }
    
    /// デフォルト設定でEncryptionManagerを初期化する
    public init() {
        // 実際のアプリでは、Keychainから取得するか、セキュアに生成する
        self.symmetricKey = SymmetricKey(size: .bits256)
        self.keychainManager = nil
    }
    
    /// カスタム設定でEncryptionManagerを初期化する
    /// - Parameter config: 暗号化設定
    /// - Throws: キー生成に失敗した場合のエラー
    public init(config: EncryptionConfig) throws {
        if config.useKeychain {
            self.keychainManager = KeychainManager()
            
            // Keychainからキーを取得または新規生成
            if let existingKeyData = keychainManager?.retrieve(forKey: config.keychainKeyId),
               let keyData = Data(base64Encoded: existingKeyData) {
                self.symmetricKey = SymmetricKey(data: keyData)
            } else {
                // 新しいキーを生成してKeychainに保存
                let newKey = SymmetricKey(size: config.keySize)
                let keyData = newKey.withUnsafeBytes { Data($0) }
                let base64Key = keyData.base64EncodedString()
                
                do {
                    try keychainManager?.store(base64Key, forKey: config.keychainKeyId)
                    self.symmetricKey = newKey
                } catch {
                    throw EncryptionError.keyGenerationFailed("Failed to store key in Keychain: \(error.localizedDescription)")
                }
            }
        } else {
            self.symmetricKey = SymmetricKey(size: config.keySize)
            self.keychainManager = nil
        }
    }
    
    /// データを暗号化する
    /// - Parameter data: 暗号化するデータ
    /// - Returns: 暗号化されたデータ
    /// - Throws: 暗号化に失敗した場合のエラー
    public func encrypt(_ data: Data) async throws -> Data {
        do {
            let encryptedData = try AES.GCM.seal(data, using: symmetricKey)
            guard let combinedData = encryptedData.combined else {
                throw EncryptionError.encryptionFailed("Failed to create combined encrypted data")
            }
            return combinedData
        } catch let error as EncryptionError {
            throw error
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
        // 12バイトのnonce + 16バイトのtag + 最小データサイズ
        return data.count >= 28
    }
    
    /// 暗号化されたデータのメタデータを取得する
    /// - Parameter encryptedData: 暗号化されたデータ
    /// - Returns: メタデータ情報（サイズ、推定暗号化状態など）
    public func getEncryptionMetadata(_ encryptedData: Data) -> EncryptionMetadata {
        let isLikelyEncrypted = isEncrypted(encryptedData)
        let overhead = isLikelyEncrypted ? 28 : 0 // nonce + tag
        let estimatedOriginalSize = max(0, encryptedData.count - overhead)
        
        return EncryptionMetadata(
            encryptedSize: encryptedData.count,
            estimatedOriginalSize: estimatedOriginalSize,
            isLikelyEncrypted: isLikelyEncrypted,
            encryptionOverhead: overhead
        )
    }
    
    /// 複数データの一括暗号化
    /// - Parameter dataItems: 暗号化するデータの配列
    /// - Returns: 暗号化されたデータの配列
    /// - Throws: いずれかの暗号化に失敗した場合のエラー
    public func encryptBatch(_ dataItems: [Data]) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: (Int, Data).self) { group in
            for (index, data) in dataItems.enumerated() {
                group.addTask {
                    let encryptedData = try await self.encrypt(data)
                    return (index, encryptedData)
                }
            }
            
            var results: [(Int, Data)] = []
            for try await result in group {
                results.append(result)
            }
            
            // 元の順序を維持
            results.sort { $0.0 < $1.0 }
            return results.map { $0.1 }
        }
    }
    
    /// 複数データの一括復号化
    /// - Parameter encryptedDataItems: 暗号化されたデータの配列
    /// - Returns: 復号化されたデータの配列
    /// - Throws: いずれかの復号化に失敗した場合のエラー
    public func decryptBatch(_ encryptedDataItems: [Data]) async throws -> [Data] {
        return try await withThrowingTaskGroup(of: (Int, Data).self) { group in
            for (index, encryptedData) in encryptedDataItems.enumerated() {
                group.addTask {
                    let decryptedData = try await self.decrypt(encryptedData)
                    return (index, decryptedData)
                }
            }
            
            var results: [(Int, Data)] = []
            for try await result in group {
                results.append(result)
            }
            
            // 元の順序を維持
            results.sort { $0.0 < $1.0 }
            return results.map { $0.1 }
        }
    }
}

/// 暗号化メタデータ
public struct EncryptionMetadata {
    public let encryptedSize: Int
    public let estimatedOriginalSize: Int
    public let isLikelyEncrypted: Bool
    public let encryptionOverhead: Int
    
    /// 圧縮率（暗号化による膨張率の逆数）
    public var compressionRatio: Double {
        guard estimatedOriginalSize > 0 else { return 0.0 }
        return Double(estimatedOriginalSize) / Double(encryptedSize)
    }
    
    /// 暗号化による膨張率
    public var expansionRatio: Double {
        guard estimatedOriginalSize > 0 else { return 0.0 }
        return Double(encryptedSize) / Double(estimatedOriginalSize)
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