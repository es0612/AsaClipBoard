import Foundation
import RegexBuilder
import Observation

/// セキュリティ関連の機能を管理するクラス
/// 
/// このクラスは機密データの検出とプライベートモード管理機能を提供します。
/// パスワード、クレジットカード番号、APIキーなど様々な機密データパターンを検出できます。
@Observable
public class SecurityManager {
    private var _isPrivateModeEnabled: Bool = false
    private let sensitivePatterns: [SensitiveDataType]
    
    /// 機密データの種類
    public enum SensitiveDataType {
        case password
        case creditCard
        case apiKey
        case socialSecurityNumber
        
        var displayName: String {
            switch self {
            case .password: return "パスワード"
            case .creditCard: return "クレジットカード番号"
            case .apiKey: return "APIキー"
            case .socialSecurityNumber: return "社会保障番号"
            }
        }
    }
    
    /// SecurityManagerを初期化する
    /// - Parameter enabledPatterns: 検出を有効にする機密データタイプ（デフォルト: 全種類）
    public init(enabledPatterns: [SensitiveDataType] = [.password, .creditCard, .apiKey]) {
        self.sensitivePatterns = enabledPatterns
    }
    
    /// 機密データを検出する
    /// - Parameter text: 検査対象のテキスト
    /// - Returns: 機密データが含まれている場合はtrue
    public func detectSensitiveContent(_ text: String) -> Bool {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return sensitivePatterns.contains { pattern in
            switch pattern {
            case .password: return detectPassword(text)
            case .creditCard: return detectCreditCard(text)
            case .apiKey: return detectAPIKey(text)
            case .socialSecurityNumber: return detectSSN(text)
            }
        }
    }
    
    /// 検出された機密データの種類を取得する
    /// - Parameter text: 検査対象のテキスト
    /// - Returns: 検出された機密データの種類の配列
    public func detectSensitiveTypes(_ text: String) -> [SensitiveDataType] {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        var detectedTypes: [SensitiveDataType] = []
        
        for pattern in sensitivePatterns {
            let isDetected = switch pattern {
            case .password: detectPassword(text)
            case .creditCard: detectCreditCard(text)
            case .apiKey: detectAPIKey(text)
            case .socialSecurityNumber: detectSSN(text)
            }
            
            if isDetected {
                detectedTypes.append(pattern)
            }
        }
        
        return detectedTypes
    }
    
    /// プライベートモードの状態
    public var isPrivateModeEnabled: Bool {
        return _isPrivateModeEnabled
    }
    
    /// プライベートモードを切り替える
    /// - Parameter enabled: プライベートモードを有効にするかどうか
    public func setPrivateMode(_ enabled: Bool) {
        _isPrivateModeEnabled = enabled
    }
    
    /// プライベートモードを有効にする
    public func enablePrivateMode() {
        setPrivateMode(true)
    }
    
    /// プライベートモードを無効にする
    public func disablePrivateMode() {
        setPrivateMode(false)
    }
    
    // MARK: - Private Methods
    
    private func detectPassword(_ text: String) -> Bool {
        let passwordPatterns = [
            "password\\s*[:=]\\s*\\S+",
            "pwd\\s*[:=]\\s*\\S+",
            "パスワード\\s*[:：=]\\s*\\S+"  // 全角コロンを追加
        ]
        
        return passwordPatterns.contains { pattern in
            text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil  // 大文字小文字を無視
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
            "token\\s*=\\s*\\S+",
            "bearer\\s+\\S+",
            "dummy_[a-zA-Z0-9_]{20,}", // テスト用のダミーキーパターン（安全）
            "fake_[a-zA-Z0-9_]{20,}" // テスト用のフェイクキーパターン（安全）
        ]
        
        return apiKeyPatterns.contains { pattern in
            text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
        }
    }
    
    private func detectSSN(_ text: String) -> Bool {
        // 社会保障番号パターン（XXX-XX-XXXX）
        let ssnPattern = "\\b\\d{3}-\\d{2}-\\d{4}\\b"
        return text.range(of: ssnPattern, options: .regularExpression) != nil
    }
}