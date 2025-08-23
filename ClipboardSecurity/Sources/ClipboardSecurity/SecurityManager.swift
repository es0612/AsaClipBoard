import Foundation
import RegexBuilder
import Observation

/// セキュリティ関連の機能を管理するクラス
@Observable
public class SecurityManager {
    private var _isPrivateModeEnabled: Bool = false
    
    public init() {}
    
    /// 機密データを検出する
    /// - Parameter text: 検査対象のテキスト
    /// - Returns: 機密データが含まれている場合はtrue
    public func detectSensitiveContent(_ text: String) -> Bool {
        return detectPassword(text) || 
               detectCreditCard(text) || 
               detectAPIKey(text)
    }
    
    /// プライベートモードの状態
    public var isPrivateModeEnabled: Bool {
        return _isPrivateModeEnabled
    }
    
    /// プライベートモードを有効にする
    public func enablePrivateMode() {
        _isPrivateModeEnabled = true
    }
    
    /// プライベートモードを無効にする
    public func disablePrivateMode() {
        _isPrivateModeEnabled = false
    }
    
    // MARK: - Private Methods
    
    private func detectPassword(_ text: String) -> Bool {
        let passwordPatterns = [
            "password\\s*[:=]\\s*\\S+",
            "pwd\\s*[:=]\\s*\\S+",
            "パスワード\\s*[:=]\\s*\\S+"
        ]
        
        return passwordPatterns.contains { pattern in
            text.range(of: pattern, options: .regularExpression) != nil
        }
    }
    
    private func detectCreditCard(_ text: String) -> Bool {
        // クレジットカード番号パターン（ハイフンあり・なし）
        let creditCardPattern = "\\b(?:\\d{4}[-\\s]?){3}\\d{4}\\b"
        return text.range(of: creditCardPattern, options: .regularExpression) != nil
    }
    
    private func detectAPIKey(_ text: String) -> Bool {
        let apiKeyPatterns = [
            "API_KEY\\s*=\\s*\\S+",
            "apikey\\s*[:=]\\s*\\S+",
            "token\\s*=\\s*\\S+"
        ]
        
        return apiKeyPatterns.contains { pattern in
            text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        }
    }
}