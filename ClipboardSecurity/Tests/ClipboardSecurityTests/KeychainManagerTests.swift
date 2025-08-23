import Testing
import Foundation
@testable import ClipboardSecurity

@Suite("KeychainManager Tests")
struct KeychainManagerTests {
    
    let testKeyPrefix = "test_keychain_\(UUID().uuidString)_"
    
    @Test("Keychainへの保存と取得")
    func keychainStorageAndRetrieval() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "storage_test"
        let testValue = "test_value_123"
        
        // When
        try sut.store(testValue, forKey: testKey)
        let retrievedValue = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(retrievedValue == testValue, "Keychainから正しい値が取得される")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
    
    @Test("存在しないキーの取得")
    func retrieveNonExistentKey() async throws {
        // Given
        let sut = KeychainManager()
        let nonExistentKey = testKeyPrefix + "non_existent"
        
        // When
        let result = sut.retrieve(forKey: nonExistentKey)
        
        // Then
        #expect(result == nil, "存在しないキーはnilを返す")
    }
    
    @Test("Keychainからの削除")
    func keychainDeletion() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "deletion_test"
        let testValue = "test_delete_value"
        
        // 事前にデータを保存
        try sut.store(testValue, forKey: testKey)
        #expect(sut.retrieve(forKey: testKey) == testValue)
        
        // When
        sut.delete(forKey: testKey)
        
        // Then
        #expect(sut.retrieve(forKey: testKey) == nil, "削除後はnilを返す")
    }
    
    @Test("同じキーでの上書き")
    func keychainOverwrite() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "overwrite_test"
        let originalValue = "original_value"
        let newValue = "new_value"
        
        // When
        try sut.store(originalValue, forKey: testKey)
        try sut.store(newValue, forKey: testKey) // 上書き
        let retrievedValue = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(retrievedValue == newValue, "新しい値で上書きされる")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
    
    @Test("空の文字列の保存と取得")
    func emptyStringStorage() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "empty_string_test"
        let emptyValue = ""
        
        // When
        try sut.store(emptyValue, forKey: testKey)
        let result = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(result == emptyValue, "空の文字列も正しく保存・取得される")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
    
    @Test("日本語文字列の保存と取得")
    func japaneseStringStorage() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "japanese_test"
        let japaneseValue = "こんにちは世界🌍"
        
        // When
        try sut.store(japaneseValue, forKey: testKey)
        let result = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(result == japaneseValue, "日本語文字列も正しく保存・取得される")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
    
    @Test("複数のキーの管理")
    func multipleKeyManagement() async throws {
        // Given
        let sut = KeychainManager()
        let key1 = testKeyPrefix + "multi_1"
        let key2 = testKeyPrefix + "multi_2"
        let key3 = testKeyPrefix + "multi_3"
        let value1 = "value1"
        let value2 = "value2"
        let value3 = "value3"
        
        // When
        try sut.store(value1, forKey: key1)
        try sut.store(value2, forKey: key2)
        try sut.store(value3, forKey: key3)
        
        let result1 = sut.retrieve(forKey: key1)
        let result2 = sut.retrieve(forKey: key2)
        let result3 = sut.retrieve(forKey: key3)
        
        // Then
        #expect(result1 == value1, "キー1の値が正しく取得される")
        #expect(result2 == value2, "キー2の値が正しく取得される")
        #expect(result3 == value3, "キー3の値が正しく取得される")
        
        // Cleanup
        sut.delete(forKey: key1)
        sut.delete(forKey: key2)
        sut.delete(forKey: key3)
    }
    
    @Test("長い文字列の保存と取得")
    func longStringStorage() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "long_string_test"
        let longValue = String(repeating: "A", count: 10000)
        
        // When
        try sut.store(longValue, forKey: testKey)
        let result = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(result == longValue, "長い文字列も正しく保存・取得される")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
    
    @Test("existsメソッドのテスト")
    func existsMethod() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "exists_test"
        let testValue = "exists_value"
        
        // When & Then
        #expect(sut.exists(forKey: testKey) == false, "存在しないキーはfalseを返す")
        
        try sut.store(testValue, forKey: testKey)
        #expect(sut.exists(forKey: testKey) == true, "存在するキーはtrueを返す")
        
        sut.delete(forKey: testKey)
        #expect(sut.exists(forKey: testKey) == false, "削除後はfalseを返す")
    }
    
    @Test("特殊文字を含むキーの処理")
    func specialCharacterKeys() async throws {
        // Given
        let sut = KeychainManager()
        let specialKeys = [
            testKeyPrefix + "key.with.dots",
            testKeyPrefix + "key-with-dashes", 
            testKeyPrefix + "key_with_underscores",
            testKeyPrefix + "key with spaces",
            testKeyPrefix + "キー日本語"
        ]
        let testValue = "special_key_value"
        
        // When & Then
        for key in specialKeys {
            try sut.store(testValue, forKey: key)
            let result = sut.retrieve(forKey: key)
            #expect(result == testValue, "特殊文字を含むキー '\(key)' も正しく処理される")
            sut.delete(forKey: key)
        }
    }
    
    @Test("バッチ保存と取得")
    func batchOperations() async throws {
        // Given
        let sut = KeychainManager()
        let batchData = [
            testKeyPrefix + "batch1": "value1",
            testKeyPrefix + "batch2": "value2",
            testKeyPrefix + "batch3": "value3"
        ]
        
        // When
        try sut.storeBatch(batchData)
        let keys = Array(batchData.keys)
        let results = sut.retrieveBatch(keys)
        
        // Then
        #expect(results.count == 3, "バッチ取得で3つの値が取得される")
        for (key, expectedValue) in batchData {
            #expect(results[key] == expectedValue, "キー'\(key)'の値が正しく取得される")
        }
        
        // Cleanup
        for key in keys {
            sut.delete(forKey: key)
        }
    }
    
    @Test("空キーのエラーハンドリング")
    func emptyKeyHandling() async throws {
        // Given
        let sut = KeychainManager()
        let emptyKey = ""
        
        // When & Then
        do {
            try sut.store("value", forKey: emptyKey)
            #expect(Bool(false), "空キーはエラーを投げるべき")
        } catch KeychainError.storageError(let message) {
            #expect(message.contains("empty"), "適切なエラーメッセージが含まれる")
        } catch {
            #expect(Bool(false), "予期しないエラータイプ")
        }
        
        #expect(sut.retrieve(forKey: emptyKey) == nil, "空キーの取得はnilを返す")
        #expect(sut.exists(forKey: emptyKey) == false, "空キーの存在チェックはfalseを返す")
        #expect(sut.delete(forKey: emptyKey) == false, "空キーの削除はfalseを返す")
    }
    
    @Test("カスタムプレフィックス")
    func customPrefix() async throws {
        // Given
        let customPrefix = "TestApp"
        let sut = KeychainManager(keyPrefix: customPrefix)
        let testKey = "custom_prefix_test"
        let testValue = "custom_value"
        
        // When
        try sut.store(testValue, forKey: testKey)
        let result = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(result == testValue, "カスタムプレフィックスでも正しく動作する")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
    
    @Test("削除の戻り値テスト")
    func deleteReturnValue() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = testKeyPrefix + "delete_return_test"
        let testValue = "delete_test_value"
        
        // When & Then
        try sut.store(testValue, forKey: testKey)
        let deleteSuccess = sut.delete(forKey: testKey)
        let deleteNonExistent = sut.delete(forKey: testKey + "_nonexistent")
        
        #expect(deleteSuccess == true, "存在するキーの削除はtrueを返す")
        #expect(deleteNonExistent == false, "存在しないキーの削除はfalseを返す")
    }
}