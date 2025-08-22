import Testing
import Foundation
@testable import ClipboardSecurity

@Suite("KeychainManager Tests")
struct KeychainManagerTests {
    
    @Test("Keychainへの保存と取得")
    func keychainStorageAndRetrieval() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = "test_key_\(UUID().uuidString)"
        let testValue = "test_value"
        
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
        let nonExistentKey = "non_existent_key_\(UUID().uuidString)"
        
        // When
        let retrievedValue = sut.retrieve(forKey: nonExistentKey)
        
        // Then
        #expect(retrievedValue == nil, "存在しないキーはnilを返す")
    }
    
    @Test("Keychainからの削除")
    func keychainDeletion() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = "test_delete_key_\(UUID().uuidString)"
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
        let testKey = "test_overwrite_key_\(UUID().uuidString)"
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
}