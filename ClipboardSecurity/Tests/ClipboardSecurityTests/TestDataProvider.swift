import Foundation
@testable import ClipboardSecurity

/// テスト用データプロバイダー
/// 
/// GitGuardianの誤検知を避けるために、明示的にテスト用とわかる
/// データパターンを提供します。
struct TestDataProvider {
    
    /// テスト用パスワードパターン
    enum TestPassword: String, CaseIterable {
        case basic = "password: TEST_PASSWORD_NOT_REAL_123"
        case japanese = "パスワード：TEST_FAKE_PASSWORD_FOR_UNIT_TEST"
        case uppercase = "PASSWORD: TEST_PASSWORD_SECRET_123"
        case pwdFormat = "pwd=MOCK_TEST_PASSWORD"
        case complex = "password: MOCK_COMPLEX_TEST_PASSWORD_123"
        case performance = "password: MOCK_PERFORMANCE_TEST_PASSWORD_123"
        case admin = "password: MOCK_ADMIN_TEST_PASSWORD_123"
        case batch = "password: TEST_BATCH_PASSWORD_NOT_REAL_1"
        case multi = "password: MOCK_MULTI_TEST_PASSWORD_123"
        
        var value: String { rawValue }
    }
    
    /// テスト用APIキーパターン
    enum TestAPIKey: String, CaseIterable {
        case basic = "API_KEY=MOCK_API_KEY_1234567890abcdef1234567890_NOT_REAL"
        case japanese = "APIキー: TEST_API_KEY_abcdef1234567890123456_FAKE"
        case batch = "API_KEY=MOCK_BATCH_API_KEY_12345678901234567890_FAKE"
        case complex = "API token: dummy_test_key_for_api_access_12345"
        case audit = "API key exposure: dummy_api_key_123456789012345"
        
        var value: String { rawValue }
    }
    
    /// テスト用クレジットカード番号（標準的なテスト用番号）
    enum TestCreditCard: String, CaseIterable {
        case visa = "4111-1111-1111-1111"
        case mastercard = "5555-5555-5555-4444"
        case discover = "6011-1111-1111-1117"
        
        var value: String { rawValue }
    }
    
    /// 複合テストデータ
    struct ComplexTestData {
        let description: String
        let content: String
        let expectedSensitiveTypes: [SecurityManager.SensitiveDataType]
        
        static let samples: [ComplexTestData] = [
            ComplexTestData(
                description: "複数機密データ混在",
                content: "password: MOCK_MULTI_TEST_PASSWORD_123 and card: 4111-1111-1111-1111",
                expectedSensitiveTypes: [.password, .creditCard]
            ),
            ComplexTestData(
                description: "セキュリティレポート形式",
                content: """
                Security audit findings:
                - Found password: MOCK_ADMIN_TEST_PASSWORD_123
                - Credit card detected: 5555-5555-5555-4444
                - API key exposure: dummy_api_key_123456789012345
                """,
                expectedSensitiveTypes: [.password, .creditCard, .apiKey]
            ),
            ComplexTestData(
                description: "ユーザー認証情報",
                content: """
                User credentials:
                password: MOCK_COMPLEX_TEST_PASSWORD_123
                Credit card: 4111-1111-1111-1111
                API token: dummy_test_key_for_api_access_12345
                """,
                expectedSensitiveTypes: [.password, .creditCard, .apiKey]
            )
        ]
    }
    
    /// 統合テスト用データセット
    struct IntegrationTestData {
        let normal: [String] = [
            "通常のテキスト",
            "メールアドレス: user@example.com",
            "通常のテキスト1",
            "通常のテキスト2",
            "通常のテキスト3"
        ]
        
        let sensitive: [String] = [
            TestPassword.basic.value,
            TestAPIKey.basic.value,
            TestCreditCard.visa.value
        ]
        
        let mixed: [String] = [
            "通常のテキスト1",
            TestPassword.batch.value,
            "通常のテキスト2", 
            TestAPIKey.batch.value,
            "通常のテキスト3"
        ]
    }
    
    /// パフォーマンステスト用データ
    struct PerformanceTestData {
        static func largeSensitiveText(baseText: String = "通常のテキスト。", repetitions: Int = 500) -> String {
            return String(repeating: baseText, count: repetitions) + TestPassword.performance.value
        }
        
        static func largeNormalText(baseText: String = "パフォーマンステスト用の長いテキスト。", repetitions: Int = 1000) -> String {
            return String(repeating: baseText, count: repetitions)
        }
    }
    
    /// ランダムテストデータ生成器
    struct RandomTestData {
        static func generateTestPassword() -> String {
            return "password: TEST_RANDOM_\(UUID().uuidString.prefix(8))_NOT_REAL"
        }
        
        static func generateTestAPIKey() -> String {
            return "API_KEY=MOCK_RANDOM_\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))_FAKE"
        }
        
        static func generateTestKeychain() -> String {
            return "test_keychain_\(UUID().uuidString)"
        }
    }
    
    /// テストデータの検証
    /// GitGuardianが誤検知しないパターンかチェック
    static func isGitGuardianSafe(_ text: String) -> Bool {
        let safePatterns = [
            "TEST_", "MOCK_", "FAKE_", "DUMMY_",
            "_NOT_REAL", "_FAKE", "_FOR_TEST", "_FOR_TESTING"
        ]
        
        return safePatterns.contains { pattern in
            text.contains(pattern)
        }
    }
    
    /// 全テストデータのGitGuardian安全性チェック
    static func validateAllTestData() -> Bool {
        var allSafe = true
        
        // パスワードパターンのチェック
        for password in TestPassword.allCases {
            if !isGitGuardianSafe(password.value) {
                print("⚠️ Unsafe password pattern: \(password.value)")
                allSafe = false
            }
        }
        
        // APIキーパターンのチェック  
        for apiKey in TestAPIKey.allCases {
            if !isGitGuardianSafe(apiKey.value) {
                print("⚠️ Unsafe API key pattern: \(apiKey.value)")
                allSafe = false
            }
        }
        
        return allSafe
    }
}