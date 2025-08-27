import Foundation

/// クリップボード関連のエラーを定義する包括的なエラー型
public enum ClipboardError: Error, CustomStringConvertible, Equatable {
    
    // MARK: - データ関連エラー
    case dataCorruption(underlyingError: Error?)
    case invalidData(expected: String, actual: String?)
    case insufficientMemory(availableMemory: Double, requiredMemory: Double)
    case dataTooLarge(size: Int, maxSize: Int)
    
    // MARK: - 操作関連エラー
    case operationFailed(operation: String)
    case operationTimeout(operation: String, timeout: TimeInterval)
    case operationCancelled(operation: String)
    case invalidInput(message: String)
    
    // MARK: - システム関連エラー
    case systemFailure(component: String)
    case networkError(reason: String)
    case permissionDenied(resource: String)
    case temporaryUnavailable(retryAfter: TimeInterval)
    
    // MARK: - セキュリティ関連エラー
    case securityViolation(action: String)
    case encryptionFailed(reason: String)
    case authenticationFailed(reason: String)
    
    // MARK: - 同期関連エラー
    case syncConflict(itemId: String)
    case cloudKitError(underlyingError: Error)
    case offlineMode(reason: String)
    
    /// エラーコードを取得
    public var errorCode: String {
        switch self {
        case .dataCorruption: return "CLIPBOARD_DATA_CORRUPTION"
        case .invalidData: return "CLIPBOARD_INVALID_DATA"
        case .insufficientMemory: return "CLIPBOARD_INSUFFICIENT_MEMORY"
        case .dataTooLarge: return "CLIPBOARD_DATA_TOO_LARGE"
        case .operationFailed: return "CLIPBOARD_OPERATION_FAILED"
        case .operationTimeout: return "CLIPBOARD_OPERATION_TIMEOUT"
        case .operationCancelled: return "CLIPBOARD_OPERATION_CANCELLED"
        case .invalidInput: return "CLIPBOARD_INVALID_INPUT"
        case .systemFailure: return "CLIPBOARD_SYSTEM_FAILURE"
        case .networkError: return "CLIPBOARD_NETWORK_ERROR"
        case .permissionDenied: return "CLIPBOARD_PERMISSION_DENIED"
        case .temporaryUnavailable: return "CLIPBOARD_TEMPORARY_UNAVAILABLE"
        case .securityViolation: return "CLIPBOARD_SECURITY_VIOLATION"
        case .encryptionFailed: return "CLIPBOARD_ENCRYPTION_FAILED"
        case .authenticationFailed: return "CLIPBOARD_AUTHENTICATION_FAILED"
        case .syncConflict: return "CLIPBOARD_SYNC_CONFLICT"
        case .cloudKitError: return "CLIPBOARD_CLOUDKIT_ERROR"
        case .offlineMode: return "CLIPBOARD_OFFLINE_MODE"
        }
    }
    
    /// エラーの重要度を取得
    public var severity: ErrorSeverity {
        switch self {
        case .dataCorruption, .systemFailure, .securityViolation:
            return .high
        case .insufficientMemory, .operationTimeout, .networkError, .encryptionFailed, .authenticationFailed:
            return .medium
        case .invalidInput, .operationCancelled, .temporaryUnavailable, .offlineMode:
            return .low
        default:
            return .medium
        }
    }
    
    /// 復旧可能かどうかを判定
    public var isRecoverable: Bool {
        switch self {
        case .temporaryUnavailable, .networkError, .operationTimeout, .insufficientMemory:
            return true
        case .dataCorruption, .securityViolation, .systemFailure:
            return false
        default:
            return true
        }
    }
    
    /// ユーザー向けのローカライズされた説明
    public var localizedDescription: String {
        switch self {
        case .dataCorruption(let underlyingError):
            if let underlying = underlyingError {
                return "データが破損しています: \(underlying.localizedDescription)"
            }
            return "データが破損しています"
        case .invalidData(let expected, let actual):
            return "無効なデータ形式です。期待される形式: \(expected), 実際の形式: \(actual ?? "不明")"
        case .insufficientMemory(let available, let required):
            return "メモリが不足しています。利用可能: \(available)MB, 必要: \(required)MB"
        case .dataTooLarge(let size, let maxSize):
            return "データサイズが大きすぎます。サイズ: \(size), 上限: \(maxSize)"
        case .operationFailed(let operation):
            return "操作が失敗しました: \(operation)"
        case .operationTimeout(let operation, let timeout):
            return "操作がタイムアウトしました: \(operation) (制限時間: \(timeout)秒)"
        case .operationCancelled(let operation):
            return "操作がキャンセルされました: \(operation)"
        case .invalidInput(let message):
            return "入力が無効です: \(message)"
        case .systemFailure(let component):
            return "システムエラーが発生しました: \(component)"
        case .networkError(let reason):
            return "ネットワークエラー: \(reason)"
        case .permissionDenied(let resource):
            return "アクセス許可が拒否されました: \(resource)"
        case .temporaryUnavailable(let retryAfter):
            return "一時的に利用できません。\(retryAfter)秒後に再試行してください"
        case .securityViolation(let action):
            return "セキュリティ違反: \(action)"
        case .encryptionFailed(let reason):
            return "暗号化に失敗しました: \(reason)"
        case .authenticationFailed(let reason):
            return "認証に失敗しました: \(reason)"
        case .syncConflict(let itemId):
            return "同期競合が発生しました: \(itemId)"
        case .cloudKitError(let underlyingError):
            return "CloudKitエラー: \(underlyingError.localizedDescription)"
        case .offlineMode(let reason):
            return "オフラインモード: \(reason)"
        }
    }
    
    /// 技術者向けの詳細説明
    public var description: String {
        return "[\(errorCode)] \(localizedDescription) (重要度: \(severity), 復旧可能: \(isRecoverable))"
    }
    
    // MARK: - Equatable
    public static func == (lhs: ClipboardError, rhs: ClipboardError) -> Bool {
        return lhs.errorCode == rhs.errorCode
    }
}

/// エラーの重要度を定義
public enum ErrorSeverity: String, CaseIterable, Comparable {
    case low = "低"
    case medium = "中"
    case high = "高"
    
    public static func < (lhs: ErrorSeverity, rhs: ErrorSeverity) -> Bool {
        let order: [ErrorSeverity] = [.low, .medium, .high]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

/// エラーコンテキスト情報を管理するクラス
public class ErrorContext {
    private var contextData: [String: Any] = [:]
    
    public init() {}
    
    /// コンテキスト情報を追加
    public func addContext<T>(_ key: String, _ value: T) {
        contextData[key] = value
    }
    
    /// コンテキスト情報を取得
    public func getContext(_ key: String) -> Any? {
        return contextData[key]
    }
    
    /// すべてのコンテキスト情報を取得
    public func getAllContext() -> [String: Any] {
        return contextData
    }
    
    /// エラーにコンテキスト情報を付加
    public func enrichError(_ error: ClipboardError) -> EnrichedClipboardError {
        return EnrichedClipboardError(error: error, context: contextData)
    }
}

/// コンテキスト情報付きのエラー
public struct EnrichedClipboardError {
    public let error: ClipboardError
    public let context: [String: Any]
    public let timestamp: Date
    
    public init(error: ClipboardError, context: [String: Any]) {
        self.error = error
        self.context = context
        self.timestamp = Date()
    }
}