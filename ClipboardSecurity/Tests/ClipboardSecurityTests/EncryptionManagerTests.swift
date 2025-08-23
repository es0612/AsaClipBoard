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
    
    @Test("暗号化データの検出")
    func encryptedDataDetection() async throws {
        // Given
        let sut = EncryptionManager()
        let originalData = "Test data for encryption".data(using: .utf8)!
        
        // When
        let encryptedData = try await sut.encrypt(originalData)
        
        // Then
        #expect(sut.isEncrypted(encryptedData) == true, "暗号化されたデータが正しく検出される")
        #expect(sut.isEncrypted(originalData) == false, "平文データは暗号化されていないと判定される")
        #expect(sut.isEncrypted(Data()) == false, "空データは暗号化されていないと判定される")
    }
    
    @Test("日本語データの暗号化")
    func japaneseDataEncryption() async throws {
        // Given
        let sut = EncryptionManager()
        let japaneseText = "機密情報：パスワードは秘密です🔐"
        let japaneseData = japaneseText.data(using: .utf8)!
        
        // When
        let encryptedData = try await sut.encrypt(japaneseData)
        let decryptedData = try await sut.decrypt(encryptedData)
        
        // Then
        #expect(encryptedData != japaneseData, "日本語データが暗号化される")
        #expect(decryptedData == japaneseData, "日本語データが正しく復号化される")
        
        // 復号化されたデータを文字列として確認
        let decryptedString = String(data: decryptedData, encoding: .utf8)
        #expect(decryptedString == japaneseText, "復号化された文字列が正しい")
    }
    
    @Test("バイナリデータの暗号化")
    func binaryDataEncryption() async throws {
        // Given
        let sut = EncryptionManager()
        var binaryData = Data()
        for i in 0..<256 {
            binaryData.append(UInt8(i))
        }
        
        // When
        let encryptedData = try await sut.encrypt(binaryData)
        let decryptedData = try await sut.decrypt(encryptedData)
        
        // Then
        #expect(encryptedData != binaryData, "バイナリデータが暗号化される")
        #expect(decryptedData == binaryData, "バイナリデータが正しく復号化される")
    }
    
    @Test("複数回の暗号化・復号化")
    func multipleEncryptionDecryption() async throws {
        // Given
        let sut = EncryptionManager()
        let originalData = "Multiple encryption test".data(using: .utf8)!
        
        // When & Then - 複数回の暗号化・復号化を実行
        var currentData = originalData
        
        for i in 1...5 {
            let encryptedData = try await sut.encrypt(currentData)
            let decryptedData = try await sut.decrypt(encryptedData)
            
            #expect(encryptedData != currentData, "第\(i)回暗号化が成功")
            #expect(decryptedData == currentData, "第\(i)回復号化が成功")
            
            currentData = decryptedData
        }
        
        #expect(currentData == originalData, "最終的に元のデータと一致")
    }
    
    @Test("暗号化の一意性確認")
    func encryptionUniqueness() async throws {
        // Given
        let sut1 = EncryptionManager()
        let sut2 = EncryptionManager()
        let testData = "Uniqueness test data".data(using: .utf8)!
        
        // When
        let encrypted1 = try await sut1.encrypt(testData)
        let encrypted2 = try await sut1.encrypt(testData) // 同じマネージャーで再暗号化
        let encrypted3 = try await sut2.encrypt(testData) // 異なるマネージャーで暗号化
        
        // Then
        // AES-GCMは同じデータでも異なるnonceを使用するため、異なる暗号化結果になる
        #expect(encrypted1 != encrypted2, "同じデータの複数回暗号化は異なる結果になる")
        #expect(encrypted1 != encrypted3, "異なるマネージャーでの暗号化は異なる結果になる")
        #expect(encrypted2 != encrypted3, "すべての暗号化結果が異なる")
        
        // しかし復号化結果は同じになる（同じキーの場合）
        let decrypted1 = try await sut1.decrypt(encrypted1)
        let decrypted2 = try await sut1.decrypt(encrypted2)
        
        #expect(decrypted1 == testData, "第1回暗号化データが正しく復号化される")
        #expect(decrypted2 == testData, "第2回暗号化データが正しく復号化される")
    }
    
    @Test("異なるキーでの復号化失敗")
    func differentKeyDecryptionFailure() async throws {
        // Given
        let sut1 = EncryptionManager()
        let sut2 = EncryptionManager() // 異なるキーを持つマネージャー
        let testData = "Key test data".data(using: .utf8)!
        
        // When
        let encryptedData = try await sut1.encrypt(testData)
        
        // Then - 異なるキーでの復号化は失敗すべき
        do {
            _ = try await sut2.decrypt(encryptedData)
            #expect(Bool(false), "異なるキーでの復号化は失敗すべき")
        } catch {
            #expect(error is EncryptionError, "適切なエラーが発生する")
        }
    }
    
    @Test("パフォーマンステスト")
    func performanceTest() async throws {
        // Given
        let sut = EncryptionManager()
        let testData = String(repeating: "Performance test data. ", count: 1000).data(using: .utf8)!
        
        // When & Then - 暗号化パフォーマンス
        let encryptStartTime = Date()
        let encryptedData = try await sut.encrypt(testData)
        let encryptDuration = Date().timeIntervalSince(encryptStartTime)
        
        #expect(encryptDuration < 1.0, "暗号化は1秒以内に完了すべき")
        
        // 復号化パフォーマンス
        let decryptStartTime = Date()
        let decryptedData = try await sut.decrypt(encryptedData)
        let decryptDuration = Date().timeIntervalSince(decryptStartTime)
        
        #expect(decryptDuration < 1.0, "復号化は1秒以内に完了すべき")
        #expect(decryptedData == testData, "パフォーマンステスト後もデータが正しい")
    }
    
    @Test("エラーハンドリングの詳細確認")
    func errorHandlingDetails() async throws {
        // Given
        let sut = EncryptionManager()
        
        // When & Then - 様々な不正データでのエラーハンドリング
        let invalidDataCases: [Data] = [
            Data([0x00]), // 1バイト
            Data([0x00, 0x01, 0x02]), // 3バイト
            Data(repeating: 0xFF, count: 10), // 10バイト
            Data(repeating: 0x00, count: 27), // 27バイト（最小サイズ-1）
            "corrupted data".data(using: .utf8)! // 不正な文字列データ
        ]
        
        for (index, invalidData) in invalidDataCases.enumerated() {
            do {
                _ = try await sut.decrypt(invalidData)
                #expect(Bool(false), "不正データケース\(index + 1)の復号化は失敗すべき")
            } catch let error as EncryptionError {
                #expect(error.errorDescription?.contains("Failed to decrypt") == true, 
                       "ケース\(index + 1): 適切なエラーメッセージが含まれる")
            } catch {
                #expect(Bool(false), "ケース\(index + 1): 予期しないエラータイプ")
            }
        }
    }
}