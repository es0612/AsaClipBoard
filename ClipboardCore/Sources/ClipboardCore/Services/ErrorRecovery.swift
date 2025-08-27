import Foundation
import Observation

/// エラー復旧管理クラス
public class ErrorRecoveryManager {
    private let logger = ErrorLogger.shared
    private let maxRetryAttempts = 3
    private let baseRetryDelay: TimeInterval = 1.0
    
    public init() {}
    
    /// エラーからの復旧を試行
    public func attemptRecovery(
        from error: ClipboardError,
        using recoveryAction: @escaping () async -> Bool
    ) async -> Bool {
        logger.logError(error, context: "復旧試行開始")
        
        guard error.isRecoverable else {
            logger.logError(.operationFailed(operation: "復旧不可能なエラー"), context: error.description)
            return false
        }
        
        for attempt in 1...maxRetryAttempts {
            do {
                // 指数バックオフで待機
                let delay = baseRetryDelay * pow(2.0, Double(attempt - 1))
                try await Task.sleep(for: .seconds(delay))
                
                logger.logError(.operationFailed(operation: "復旧試行 \(attempt)/\(maxRetryAttempts)"), context: error.description)
                
                let success = await recoveryAction()
                if success {
                    logger.logError(.operationFailed(operation: "復旧成功"), context: "試行回数: \(attempt)")
                    ErrorMetrics.shared.recordRecovery(error, attempts: attempt)
                    return true
                }
                
            } catch {
                logger.logError(.operationFailed(operation: "復旧中にエラー"), context: error.localizedDescription)
            }
        }
        
        logger.logError(.operationFailed(operation: "復旧失敗"), context: "最大試行回数に達しました")
        ErrorMetrics.shared.recordFailedRecovery(error)
        return false
    }
    
    /// 特定エラータイプの復旧戦略を実行
    public func executeRecoveryStrategy(for error: ClipboardError) async -> Bool {
        switch error {
        case .temporaryUnavailable(let retryAfter):
            return await handleTemporaryUnavailable(retryAfter: retryAfter)
        case .insufficientMemory:
            return await handleInsufficientMemory()
        case .networkError:
            return await handleNetworkError()
        case .operationTimeout:
            return await handleOperationTimeout()
        default:
            return await attemptGenericRecovery(from: error)
        }
    }
    
    // MARK: - 個別復旧戦略
    
    private func handleTemporaryUnavailable(retryAfter: TimeInterval) async -> Bool {
        do {
            try await Task.sleep(for: .seconds(retryAfter))
            return true
        } catch {
            return false
        }
    }
    
    private func handleInsufficientMemory() async -> Bool {
        // メモリクリーンアップ処理の実行
        await performMemoryCleanup()
        
        // メモリ状況を再確認
        let memoryInfo = getMemoryInfo()
        return memoryInfo.availableMemory > memoryInfo.requiredMemory * 0.5
    }
    
    private func handleNetworkError() async -> Bool {
        // ネットワーク接続の確認
        return await checkNetworkConnectivity()
    }
    
    private func handleOperationTimeout() async -> Bool {
        // タイムアウト設定を動的に調整
        return await adjustTimeoutSettings()
    }
    
    private func attemptGenericRecovery(from error: ClipboardError) async -> Bool {
        // 汎用復旧戦略
        do {
            try await Task.sleep(for: .seconds(1.0))
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - ヘルパーメソッド
    
    private func performMemoryCleanup() async {
        // メモリクリーンアップの実装
        // 実際の実装では、不要なキャッシュの削除やガベージコレクションの実行などを行う
        logger.logError(.operationFailed(operation: "メモリクリーンアップ実行"), context: "復旧処理")
    }
    
    private func getMemoryInfo() -> (availableMemory: Double, requiredMemory: Double) {
        // メモリ情報の取得
        let processInfo = ProcessInfo.processInfo
        let physicalMemory = Double(processInfo.physicalMemory)
        return (availableMemory: physicalMemory / (1024 * 1024), requiredMemory: 100.0) // 100MB要求と仮定
    }
    
    private func checkNetworkConnectivity() async -> Bool {
        // ネットワーク接続確認の実装
        // 実際の実装では、Reachabilityやネットワーク疎通確認を行う
        return true // 簡単化のため常にtrueを返す
    }
    
    private func adjustTimeoutSettings() async -> Bool {
        // タイムアウト設定調整の実装
        // 実際の実装では、システム負荷に応じてタイムアウト値を動的に調整
        return true // 簡単化のため常にtrueを返す
    }
}

/// 非同期エラーハンドラー
public actor AsyncErrorHandler {
    private var errorCallback: ((ClipboardError) -> Void)?
    
    public init() {}
    
    /// エラーコールバックを設定
    public func setErrorCallback(_ callback: @escaping (ClipboardError) -> Void) {
        errorCallback = callback
    }
    
    /// エラーを非同期で処理
    public func handleError(_ error: ClipboardError) async {
        ErrorLogger.shared.logError(error, context: "非同期エラー処理")
        
        // コールバックがある場合は実行
        if let callback = errorCallback {
            callback(error)
        }
        
        // 重要度が高い場合は即座に復旧を試行
        if error.severity == .high && error.isRecoverable {
            let recoveryManager = ErrorRecoveryManager()
            let recovered = await recoveryManager.executeRecoveryStrategy(for: error)
            
            if recovered {
                ErrorLogger.shared.logError(.operationFailed(operation: "非同期復旧成功"), context: error.description)
            }
        }
    }
}

/// エラー統計情報
public struct ErrorStatistics {
    public let totalErrors: Int
    public let errorsByType: [String: Int]
    public let errorsBySeverity: [ErrorSeverity: Int]
    public let recoverySuccessRate: Double
    public let averageRecoveryTime: TimeInterval
    
    public init(
        totalErrors: Int,
        errorsByType: [String: Int],
        errorsBySeverity: [ErrorSeverity: Int],
        recoverySuccessRate: Double,
        averageRecoveryTime: TimeInterval
    ) {
        self.totalErrors = totalErrors
        self.errorsByType = errorsByType
        self.errorsBySeverity = errorsBySeverity
        self.recoverySuccessRate = recoverySuccessRate
        self.averageRecoveryTime = averageRecoveryTime
    }
}

/// エラーメトリクス収集クラス
@Observable
public class ErrorMetrics {
    public static let shared = ErrorMetrics()
    
    private var errorCounts: [String: Int] = [:]
    private var severityCounts: [ErrorSeverity: Int] = [:]
    private var recoveryAttempts: [String: Int] = [:]
    private var successfulRecoveries: [String: Int] = [:]
    private var recoveryTimes: [TimeInterval] = []
    
    private init() {}
    
    /// エラーを記録
    public func recordError(_ error: ClipboardError) {
        let errorCode = error.errorCode
        errorCounts[errorCode, default: 0] += 1
        severityCounts[error.severity, default: 0] += 1
    }
    
    /// 復旧成功を記録
    public func recordRecovery(_ error: ClipboardError, attempts: Int) {
        let errorCode = error.errorCode
        recoveryAttempts[errorCode, default: 0] += attempts
        successfulRecoveries[errorCode, default: 0] += 1
    }
    
    /// 復旧失敗を記録
    public func recordFailedRecovery(_ error: ClipboardError) {
        let errorCode = error.errorCode
        recoveryAttempts[errorCode, default: 0] += 1
    }
    
    /// 復旧時間を記録
    public func recordRecoveryTime(_ time: TimeInterval) {
        recoveryTimes.append(time)
        
        // 最大100件までの履歴を保持
        if recoveryTimes.count > 100 {
            recoveryTimes.removeFirst(recoveryTimes.count - 100)
        }
    }
    
    /// 統計情報を取得
    public func getStatistics() -> ErrorStatistics {
        let totalErrors = errorCounts.values.reduce(0, +)
        let totalRecoveryAttempts = recoveryAttempts.values.reduce(0, +)
        let totalSuccessfulRecoveries = successfulRecoveries.values.reduce(0, +)
        
        let recoverySuccessRate = totalRecoveryAttempts > 0 
            ? Double(totalSuccessfulRecoveries) / Double(totalRecoveryAttempts)
            : 0.0
        
        let averageRecoveryTime = recoveryTimes.isEmpty 
            ? 0.0 
            : recoveryTimes.reduce(0, +) / Double(recoveryTimes.count)
        
        return ErrorStatistics(
            totalErrors: totalErrors,
            errorsByType: errorCounts,
            errorsBySeverity: severityCounts,
            recoverySuccessRate: recoverySuccessRate,
            averageRecoveryTime: averageRecoveryTime
        )
    }
    
    /// メトリクスをリセット
    public func reset() {
        errorCounts.removeAll()
        severityCounts.removeAll()
        recoveryAttempts.removeAll()
        successfulRecoveries.removeAll()
        recoveryTimes.removeAll()
    }
}