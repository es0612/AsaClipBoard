import Testing
@testable import ClipboardSecurity

@Suite("SecurityManager Tests")
struct SecurityManagerTests {
    
    @Test("機密データ検出 - パスワードパターン")
    func detectSensitiveContentPassword() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("password: secret123") == true)
        #expect(sut.detectSensitiveContent("パスワード: abc123") == true)
        #expect(sut.detectSensitiveContent("pwd=mypassword") == true)
        #expect(sut.detectSensitiveContent("Hello World") == false)
    }
    
    @Test("機密データ検出 - クレジットカード番号")
    func detectSensitiveContentCreditCard() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("4111-1111-1111-1111") == true)
        #expect(sut.detectSensitiveContent("4111111111111111") == true)
        #expect(sut.detectSensitiveContent("1234-5678-9012-3456") == true)
        #expect(sut.detectSensitiveContent("123-456-7890") == false) // 電話番号
    }
    
    @Test("機密データ検出 - APIキー")
    func detectSensitiveContentAPIKey() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("API_KEY=sk_test_12345") == true)
        #expect(sut.detectSensitiveContent("apikey: abc123xyz789") == true)
        #expect(sut.detectSensitiveContent("token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9") == true)
        #expect(sut.detectSensitiveContent("normal text") == false)
    }
    
    @Test("プライベートモード状態管理")
    func privateModeToggle() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.isPrivateModeEnabled == false) // 初期状態
        
        // When
        sut.enablePrivateMode()
        
        // Then
        #expect(sut.isPrivateModeEnabled == true)
        
        // When
        sut.disablePrivateMode()
        
        // Then
        #expect(sut.isPrivateModeEnabled == false)
    }
}