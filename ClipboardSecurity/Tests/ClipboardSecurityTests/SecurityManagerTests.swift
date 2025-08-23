import Testing
import Foundation
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
        
        // 大文字小文字の混在
        #expect(sut.detectSensitiveContent("PASSWORD: Secret123") == true)
        #expect(sut.detectSensitiveContent("Pwd=MyPassword") == true)
        
        // 全角コロンのテスト
        #expect(sut.detectSensitiveContent("パスワード：secret123") == true)
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
        
        // スペース区切りもテスト
        #expect(sut.detectSensitiveContent("4111 1111 1111 1111") == true)
    }
    
    @Test("機密データ検出 - APIキー")
    func detectSensitiveContentAPIKey() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("API_KEY=dummy_test_12345") == true)
        #expect(sut.detectSensitiveContent("apikey: abc123xyz789") == true)
        #expect(sut.detectSensitiveContent("token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9") == true)
        #expect(sut.detectSensitiveContent("normal text") == false)
        
        // Bearer token
        #expect(sut.detectSensitiveContent("Authorization: Bearer abc123xyz") == true)
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
    
    @Test("カスタムパターン設定")
    func customPatternConfiguration() async throws {
        // Given - パスワードのみを検出するSecurityManager
        let passwordOnlyManager = SecurityManager(enabledPatterns: [.password])
        
        // When & Then
        #expect(passwordOnlyManager.detectSensitiveContent("password: secret123") == true)
        #expect(passwordOnlyManager.detectSensitiveContent("4111-1111-1111-1111") == false) // クレジットカードは検出しない
        #expect(passwordOnlyManager.detectSensitiveContent("API_KEY=test123") == false) // APIキーも検出しない
        
        // Given - クレジットカードとAPIキーのみを検出するSecurityManager  
        let cardApiManager = SecurityManager(enabledPatterns: [.creditCard, .apiKey])
        
        // When & Then
        #expect(cardApiManager.detectSensitiveContent("password: secret123") == false) // パスワードは検出しない
        #expect(cardApiManager.detectSensitiveContent("4111-1111-1111-1111") == true)
        #expect(cardApiManager.detectSensitiveContent("API_KEY=test123") == true)
    }
    
    @Test("機密データタイプ検出機能")
    func detectSensitiveTypes() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then - 単一タイプ
        let passwordTypes = sut.detectSensitiveTypes("password: secret123")
        #expect(passwordTypes.count == 1)
        #expect(passwordTypes.contains(.password))
        
        let creditCardTypes = sut.detectSensitiveTypes("4111-1111-1111-1111")
        #expect(creditCardTypes.count == 1)
        #expect(creditCardTypes.contains(.creditCard))
        
        // 複数タイプの混在
        let mixedText = "password: secret123 and card: 4111-1111-1111-1111"
        let mixedTypes = sut.detectSensitiveTypes(mixedText)
        #expect(mixedTypes.count == 2)
        #expect(mixedTypes.contains(.password))
        #expect(mixedTypes.contains(.creditCard))
        
        // 検出されない場合
        let normalTypes = sut.detectSensitiveTypes("Hello World")
        #expect(normalTypes.count == 0)
        
        // 空文字列
        let emptyTypes = sut.detectSensitiveTypes("")
        #expect(emptyTypes.count == 0)
    }
    
    @Test("エッジケースとバリデーション")
    func edgeCasesAndValidation() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then - エッジケース
        #expect(sut.detectSensitiveContent("") == false) // 空文字列
        #expect(sut.detectSensitiveContent("   ") == false) // 空白のみ
        #expect(sut.detectSensitiveContent("\n\t") == false) // 改行・タブのみ
        
        // 非常に長いテキスト
        let longText = String(repeating: "a", count: 10000) + "password: secret"
        #expect(sut.detectSensitiveContent(longText) == true)
        
        // 特殊文字を含むパスワード
        #expect(sut.detectSensitiveContent("password: p@ssw0rd!") == true)
        #expect(sut.detectSensitiveContent("pwd=複雑なパスワード") == true)
    }
    
    @Test("複合機密データ検出")
    func compositeSensitiveDataDetection() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then - 複数の機密データが含まれるテキスト
        let complexText = """
        User credentials:
        password: mySecret123
        Credit card: 4111-1111-1111-1111
        API token: dummy_test_key_for_api_access_12345
        """
        
        #expect(sut.detectSensitiveContent(complexText) == true)
        
        let detectedTypes = sut.detectSensitiveTypes(complexText)
        #expect(detectedTypes.count == 3)
        #expect(detectedTypes.contains(.password))
        #expect(detectedTypes.contains(.creditCard))
        #expect(detectedTypes.contains(.apiKey))
    }
    
    @Test("日本語機密データ検出")
    func japaneseSensitiveDataDetection() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("パスワード: 機密情報123") == true)
        #expect(sut.detectSensitiveContent("パスワード：全角コロン") == true)
        #expect(sut.detectSensitiveContent("パスワード = スペース付き") == true)
        
        // クレジットカード番号（日本語コンテキスト）
        #expect(sut.detectSensitiveContent("カード番号: 4111-1111-1111-1111") == true)
        
        // 検出されない場合
        #expect(sut.detectSensitiveContent("パスワードという単語だけ") == false)
        #expect(sut.detectSensitiveContent("こんにちは世界") == false)
    }
    
    @Test("拡張APIキーパターン")
    func extendedAPIKeyPatterns() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then - 新しいAPIキーパターン（安全なダミーパターン）
        #expect(sut.detectSensitiveContent("Authorization: Bearer abc123xyz") == true)
        #expect(sut.detectSensitiveContent("dummy_test_key_not_real_123456") == true) // ダミーパターン（安全）
        #expect(sut.detectSensitiveContent("fake_example_key_for_testing") == true) // フェイクパターン（安全）
        
        // 短すぎるキーは検出しない
        #expect(sut.detectSensitiveContent("dummy_short") == false)
    }
    
    @Test("プライベートモード拡張機能")
    func privateModeExtendedFunctionality() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then - setPrivateModeメソッドのテスト
        #expect(sut.isPrivateModeEnabled == false) // 初期状態
        
        sut.setPrivateMode(true)
        #expect(sut.isPrivateModeEnabled == true)
        
        sut.setPrivateMode(false) 
        #expect(sut.isPrivateModeEnabled == false)
        
        // 既存メソッドとの互換性確認
        sut.enablePrivateMode()
        #expect(sut.isPrivateModeEnabled == true)
        
        sut.disablePrivateMode()
        #expect(sut.isPrivateModeEnabled == false)
    }
    
    @Test("セキュリティコンテキスト分析")
    func securityContextAnalysis() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then - セキュリティ関連のコンテキスト分析
        let securityReport = """
        Security audit findings:
        - Found password: admin123
        - Credit card detected: 5555-5555-5555-4444
        - API key exposure: dummy_api_key_123456789012345
        """
        
        let types = sut.detectSensitiveTypes(securityReport)
        #expect(types.count == 3)
        
        // SensitiveDataTypeのdisplayName確認
        #expect(SecurityManager.SensitiveDataType.password.displayName == "パスワード")
        #expect(SecurityManager.SensitiveDataType.creditCard.displayName == "クレジットカード番号")
        #expect(SecurityManager.SensitiveDataType.apiKey.displayName == "APIキー")
        #expect(SecurityManager.SensitiveDataType.socialSecurityNumber.displayName == "社会保障番号")
    }
    
    @Test("パフォーマンステスト")
    func performanceTest() async throws {
        // Given
        let sut = SecurityManager()
        let largeText = String(repeating: "Normal text without sensitive data. ", count: 1000)
        
        // When & Then
        let startTime = Date()
        let result = sut.detectSensitiveContent(largeText)
        let duration = Date().timeIntervalSince(startTime)
        
        #expect(result == false)
        #expect(duration < 0.1, "大きなテキストの検出も高速であるべき")
        
        // 機密データありのケース
        let sensitiveText = largeText + "password: secret123"
        let startTime2 = Date()
        let result2 = sut.detectSensitiveContent(sensitiveText)
        let duration2 = Date().timeIntervalSince(startTime2)
        
        #expect(result2 == true)
        #expect(duration2 < 0.1, "機密データ検出も高速であるべき")
    }
}