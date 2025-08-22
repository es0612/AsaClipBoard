import Testing
import Foundation
@testable import ClipboardSecurity

@Suite("EncryptionManager Tests")
struct EncryptionManagerTests {
    
    @Test("データ暗号化と復号化")
    func dataEncryptionAndDecryption() async throws {
        // Given
        let sut = EncryptionManager()
        let originalData = "Sensitive Information".data(using: .utf8)!
        
        // When
        let encryptedData = try await sut.encrypt(originalData)
        let decryptedData = try await sut.decrypt(encryptedData)
        
        // Then
        #expect(encryptedData != originalData, "データが暗号化される")
        #expect(decryptedData == originalData, "データが正しく復号化される")
    }
    
    @Test("空データの暗号化")
    func emptyDataEncryption() async throws {
        // Given
        let sut = EncryptionManager()
        let emptyData = Data()
        
        // When
        let encryptedData = try await sut.encrypt(emptyData)
        let decryptedData = try await sut.decrypt(encryptedData)
        
        // Then
        #expect(decryptedData == emptyData, "空データも正しく処理される")
    }
    
    @Test("大容量データの暗号化")
    func largeDataEncryption() async throws {
        // Given
        let sut = EncryptionManager()
        let largeString = String(repeating: "A", count: 10000)
        let largeData = largeString.data(using: .utf8)!
        
        // When
        let encryptedData = try await sut.encrypt(largeData)
        let decryptedData = try await sut.decrypt(encryptedData)
        
        // Then
        #expect(decryptedData == largeData, "大容量データも正しく処理される")
    }
    
    @Test("不正な暗号化データの復号化")
    func invalidEncryptedDataDecryption() async throws {
        // Given
        let sut = EncryptionManager()
        let invalidData = "invalid encrypted data".data(using: .utf8)!
        
        // When & Then
        do {
            _ = try await sut.decrypt(invalidData)
            #expect(Bool(false), "無効なデータの復号化は失敗すべき")
        } catch {
            // 期待される動作：例外が発生する
            #expect(error is EncryptionError, "適切なエラーが発生する")
        }
    }
}