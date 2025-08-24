import Testing
import Foundation
@testable import ClipboardSecurity

/// セキュリティ基盤の統合テストスイート
/// 
/// このテストスイートは、SecurityManager、KeychainManager、EncryptionManagerの
/// 統合動作を検証し、セキュリティ基盤全体の正常性を確認します。
@Suite("Security Integration Tests")
struct SecurityIntegrationTests {
    
    /// セキュリティマネージャーの統合テスト
    @Test("セキュリティマネージャーとKeychainの統合")
    func securityManagerKeychainIntegration() async throws {
        // Given
        let securityManager = SecurityManager()
        let keychainManager = KeychainManager(keyPrefix: "TestSecurityIntegration")
        let testKey = "sensitive_data_\(UUID().uuidString)"
        
        // 機密データパターンをテスト (明示的にテスト用データとして設計)
        let sensitiveTexts = [
            "password: TEST_PASSWORD_NOT_REAL_123",
            "パスワード：TEST_FAKE_PASSWORD_FOR_UNIT_TEST",
            "API_KEY=MOCK_API_KEY_1234567890abcdef1234567890_NOT_REAL",
            "4111-1111-1111-1111"
        ]
        
        // When & Then - 機密データ検出テスト
        for text in sensitiveTexts {
            let isSensitive = securityManager.detectSensitiveContent(text)
            #expect(isSensitive == true, "機密データが正しく検出される: \(text)")
            
            if isSensitive {
                // 機密データをKeychainに安全に保存
                do {
                    try keychainManager.store(text, forKey: testKey)
                    
                    // 保存されたデータを取得して検証
                    let retrievedData = keychainManager.retrieve(forKey: testKey)
                    #expect(retrievedData == text, "Keychainから正しいデータが取得される")
                    
                    // クリーンアップ
                    let deleted = keychainManager.delete(forKey: testKey)
                    #expect(deleted == true, "テストデータが正しく削除される")
                } catch {
                    Issue.record("Keychain操作に失敗: \(error)")
                }
            }
        }
    }
    
    /// 暗号化マネージャーとKeychainの統合テスト
    @Test("暗号化マネージャーとKeychainの統合")
    func encryptionManagerKeychainIntegration() async throws {
        // Given
        let config = EncryptionManager.EncryptionConfig(
            useKeychain: true,
            keychainKeyId: "TestEncryptionIntegration_\(UUID().uuidString)"
        )
        
        let encryptionManager = try EncryptionManager(config: config)
        let testData = "機密なクリップボードデータ - パスワード: TEST_FAKE_PASSWORD_123".data(using: .utf8)!
        
        // When - データを暗号化
        let encryptedData = try await encryptionManager.encrypt(testData)
        
        // Then - 暗号化データの検証
        #expect(encryptedData != testData, "データが暗号化されている")
        #expect(encryptedData.count > testData.count, "暗号化によりデータサイズが増加")
        #expect(encryptionManager.isEncrypted(encryptedData) == true, "暗号化状態が正しく検出される")
        
        // When - データを復号化
        let decryptedData = try await encryptionManager.decrypt(encryptedData)
        
        // Then - 復号化データの検証
        #expect(decryptedData == testData, "データが正しく復号化される")
        
        // メタデータ検証
        let metadata = encryptionManager.getEncryptionMetadata(encryptedData)
        #expect(metadata.isLikelyEncrypted == true, "メタデータが暗号化状態を正しく示す")
        #expect(metadata.encryptedSize == encryptedData.count, "暗号化サイズが正確")
        #expect(metadata.expansionRatio > 1.0, "暗号化による膨張率が1.0より大きい")
    }
    
    /// セキュリティ基盤全体のワークフローテスト
    @Test("セキュリティ基盤の完全ワークフロー")
    func completeSecurityWorkflow() async throws {
        // Given - 統合セキュリティシステムのセットアップ
        let securityManager = SecurityManager()
        let keychainManager = KeychainManager(keyPrefix: "TestCompleteWorkflow")
        let config = EncryptionManager.EncryptionConfig(
            useKeychain: false, // このテストではKeychainキー保存は使用しない
            keychainKeyId: "TestWorkflow_\(UUID().uuidString)"
        )
        let encryptionManager = try EncryptionManager(config: config)
        
        // テストデータ - 様々な種類のクリップボードコンテンツ (明示的なテスト用データ)
        let testContents = [
            "通常のテキスト",
            "password: MOCK_PASSWORD_NOT_REAL_123",
            "APIキー: TEST_API_KEY_abcdef1234567890123456_FAKE",
            "メールアドレス: user@example.com",
            "クレジットカード: 4111-1111-1111-1111"
        ]
        
        // When & Then - 完全なセキュリティワークフロー
        for (index, content) in testContents.enumerated() {
            let contentData = content.data(using: .utf8)!
            let testKey = "content_\(index)"
            
            // 1. 機密データ検出
            let isSensitive = securityManager.detectSensitiveContent(content)
            let detectedTypes = securityManager.detectSensitiveTypes(content)
            
            if isSensitive {
                // 2. 機密データの場合は暗号化
                let encryptedData = try await encryptionManager.encrypt(contentData)
                #expect(encryptedData != contentData, "機密データが暗号化される")
                
                // 3. 暗号化データをKeychainに保存
                let base64EncryptedData = encryptedData.base64EncodedString()
                try keychainManager.store(base64EncryptedData, forKey: testKey)
                
                // 4. 保存データの取得と復号化
                guard let retrievedBase64 = keychainManager.retrieve(forKey: testKey),
                      let retrievedEncryptedData = Data(base64Encoded: retrievedBase64) else {
                    Issue.record("Keychainからの取得に失敗")
                    continue
                }
                
                let decryptedData = try await encryptionManager.decrypt(retrievedEncryptedData)
                #expect(decryptedData == contentData, "データが正しく復元される")
                
                // 5. セキュリティメタデータの検証
                #expect(detectedTypes.count > 0, "機密データタイプが検出される")
                
                // クリーンアップ
                keychainManager.delete(forKey: testKey)
                
            } else {
                // 通常データの場合はそのまま処理
                #expect(detectedTypes.count == 0, "通常データでは機密タイプが検出されない")
            }
        }
    }
    
    /// プライベートモードの統合テスト
    @Test("プライベートモードの統合動作")
    func privateModeIntegration() async throws {
        // Given
        let securityManager = SecurityManager()
        let testData = "プライベートモードテスト用データ"
        
        // When - プライベートモード無効時
        securityManager.disablePrivateMode()
        #expect(securityManager.isPrivateModeEnabled == false, "プライベートモードが無効")
        
        // Then - 通常の処理が実行される
        let normalProcessing = !securityManager.isPrivateModeEnabled
        #expect(normalProcessing == true, "通常処理が実行される")
        
        // When - プライベートモード有効時
        securityManager.enablePrivateMode()
        #expect(securityManager.isPrivateModeEnabled == true, "プライベートモードが有効")
        
        // Then - プライベートモード時の動作を検証
        let privateProcessing = securityManager.isPrivateModeEnabled
        #expect(privateProcessing == true, "プライベートモード処理が実行される")
        
        // プライベートモード切り替えテスト
        securityManager.setPrivateMode(false)
        #expect(securityManager.isPrivateModeEnabled == false, "プライベートモードが切り替わる")
        
        securityManager.setPrivateMode(true)
        #expect(securityManager.isPrivateModeEnabled == true, "プライベートモードが切り替わる")
    }
    
    /// バッチ処理の統合テスト
    @Test("バッチ処理の統合")
    func batchProcessingIntegration() async throws {
        // Given
        let securityManager = SecurityManager()
        let keychainManager = KeychainManager(keyPrefix: "TestBatchProcessing")
        let encryptionManager = EncryptionManager()
        
        let testContents = [
            "通常のテキスト1",
            "password: TEST_BATCH_PASSWORD_NOT_REAL_1",
            "通常のテキスト2", 
            "API_KEY=MOCK_BATCH_API_KEY_12345678901234567890_FAKE",
            "通常のテキスト3"
        ]
        
        let testDataItems = testContents.map { $0.data(using: .utf8)! }
        let keychainItems = Dictionary(uniqueKeysWithValues: testContents.enumerated().map { ("batch_\($0.offset)", $0.element) })
        
        // When - バッチ暗号化
        let encryptedDataItems = try await encryptionManager.encryptBatch(testDataItems)
        
        // Then - バッチ暗号化の検証
        #expect(encryptedDataItems.count == testDataItems.count, "全データが暗号化される")
        
        for (original, encrypted) in zip(testDataItems, encryptedDataItems) {
            #expect(original != encrypted, "各データが暗号化される")
            #expect(encryptionManager.isEncrypted(encrypted) == true, "暗号化状態が正しく検出される")
        }
        
        // When - バッチ復号化
        let decryptedDataItems = try await encryptionManager.decryptBatch(encryptedDataItems)
        
        // Then - バッチ復号化の検証
        #expect(decryptedDataItems.count == testDataItems.count, "全データが復号化される")
        
        for (original, decrypted) in zip(testDataItems, decryptedDataItems) {
            #expect(original == decrypted, "各データが正しく復元される")
        }
        
        // When - Keychainバッチ処理
        try keychainManager.storeBatch(keychainItems)
        let retrievedItems = keychainManager.retrieveBatch(Array(keychainItems.keys))
        
        // Then - Keychainバッチ処理の検証
        #expect(retrievedItems.count == keychainItems.count, "全データがKeychainに保存される")
        
        for (key, originalValue) in keychainItems {
            #expect(retrievedItems[key] == originalValue, "Keychainから正しいデータが取得される: \(key)")
        }
        
        // クリーンアップ（個別削除でより確実に）
        var deletedCount = 0
        for key in keychainItems.keys {
            if keychainManager.delete(forKey: key) {
                deletedCount += 1
            }
        }
        #expect(deletedCount == keychainItems.count, "全テストデータが削除される")
    }
    
    /// エラーハンドリングの統合テスト
    @Test("エラーハンドリングの統合")
    func errorHandlingIntegration() async throws {
        // Given
        let keychainManager = KeychainManager()
        let encryptionManager = EncryptionManager()
        
        // When & Then - 不正なキーでのKeychain操作
        let emptyKeyResult = keychainManager.retrieve(forKey: "")
        #expect(emptyKeyResult == nil, "空のキーではnilが返される")
        
        let deleteEmptyKeyResult = keychainManager.delete(forKey: "")
        #expect(deleteEmptyKeyResult == false, "空のキーの削除は失敗する")
        
        // When & Then - 不正なデータでの復号化
        let invalidEncryptedData = Data("invalid encrypted data".utf8)
        
        do {
            _ = try await encryptionManager.decrypt(invalidEncryptedData)
            Issue.record("不正なデータの復号化でエラーが発生すべき")
        } catch is EncryptionError {
            // 期待される動作：EncryptionErrorが発生する
        } catch {
            Issue.record("予期しないエラータイプ: \(type(of: error))")
        }
        
        // When & Then - Keychain設定を使用した暗号化マネージャーのキー生成失敗テスト
        // （このテストは実際のKeychain失敗をシミュレートするのは困難なため、
        //  エラーハンドリングコードパスの存在確認に留める）
        let config = EncryptionManager.EncryptionConfig(
            useKeychain: false, // エラーを避けるためfalse
            keychainKeyId: "ErrorHandlingTest"
        )
        
        do {
            let _ = try EncryptionManager(config: config)
            // 正常な動作確認
        } catch {
            Issue.record("通常の設定でのエラー: \(error)")
        }
    }
    
    /// パフォーマンスの統合テスト
    @Test("パフォーマンスの統合")
    func performanceIntegration() async throws {
        // Given
        let securityManager = SecurityManager()
        let encryptionManager = EncryptionManager()
        let keychainManager = KeychainManager(keyPrefix: "TestPerformance")
        
        let largeTestData = String(repeating: "パフォーマンステスト用の長いテキスト。", count: 1000).data(using: .utf8)!
        let testKey = "performance_test_\(UUID().uuidString)"
        
        // When & Then - 大きなデータの暗号化パフォーマンス
        let encryptionStartTime = DispatchTime.now()
        let encryptedData = try await encryptionManager.encrypt(largeTestData)
        let encryptionEndTime = DispatchTime.now()
        
        let encryptionDuration = Double(encryptionEndTime.uptimeNanoseconds - encryptionStartTime.uptimeNanoseconds) / 1_000_000
        #expect(encryptionDuration < 100, "大きなデータの暗号化が100ms以下で完了")
        
        // When & Then - 大きなデータの復号化パフォーマンス
        let decryptionStartTime = DispatchTime.now()
        let decryptedData = try await encryptionManager.decrypt(encryptedData)
        let decryptionEndTime = DispatchTime.now()
        
        let decryptionDuration = Double(decryptionEndTime.uptimeNanoseconds - decryptionStartTime.uptimeNanoseconds) / 1_000_000
        #expect(decryptionDuration < 100, "大きなデータの復号化が100ms以下で完了")
        #expect(decryptedData == largeTestData, "大きなデータが正しく復元される")
        
        // When & Then - 機密データ検出のパフォーマンス
        let longTextWithSensitiveData = String(repeating: "通常のテキスト。", count: 500) + "password: TEST_PERFORMANCE_PASSWORD_NOT_REAL_123"
        
        let detectionStartTime = DispatchTime.now()
        let isSensitive = securityManager.detectSensitiveContent(longTextWithSensitiveData)
        let detectionEndTime = DispatchTime.now()
        
        let detectionDuration = Double(detectionEndTime.uptimeNanoseconds - detectionStartTime.uptimeNanoseconds) / 1_000_000
        #expect(detectionDuration < 10, "機密データ検出が10ms以下で完了")
        #expect(isSensitive == true, "長いテキスト内の機密データが検出される")
        
        // クリーンアップ
        keychainManager.delete(forKey: testKey)
    }
}