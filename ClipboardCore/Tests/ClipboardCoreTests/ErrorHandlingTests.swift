import Testing
import Foundation
@testable import ClipboardCore

@Test("ClipboardError基本機能テスト")
func testClipboardErrorBasicFunctionality() async throws {
    // Given
    let underlyingError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test underlying error"])
    
    // When
    let clipboardError = ClipboardError.dataCorruption(underlyingError: underlyingError)
    
    // Then
    #expect(clipboardError.errorCode == "CLIPBOARD_DATA_CORRUPTION")
    #expect(clipboardError.localizedDescription.contains("Test underlying error"))
    #expect(clipboardError.severity == .high)
}

@Test("ErrorLogger基本機能テスト")
func testErrorLoggerBasicFunctionality() async throws {
    // Given
    let logger = ErrorLogger.shared
    let testError = ClipboardError.insufficientMemory(availableMemory: 50.0, requiredMemory: 100.0)
    
    // When
    logger.logError(testError, context: "テストコンテキスト")
    
    // Then
    let recentErrors = logger.getRecentErrors(limit: 10)
    #expect(recentErrors.count > 0)
    
    // 特定のエラーがログに記録されていることを確認
    let hasTargetError = recentErrors.contains { entry in
        entry.error.errorCode == "CLIPBOARD_INSUFFICIENT_MEMORY" && 
        entry.context == "テストコンテキスト"
    }
    #expect(hasTargetError)
}

@Test("ErrorLogger重大度フィルタリングテスト")
func testErrorLoggerSeverityFiltering() async throws {
    // Given
    let logger = ErrorLogger.shared
    logger.clearLogs() // テスト前にログをクリア
    
    // 少し待ってクリアが完了するのを待つ
    try await Task.sleep(for: .milliseconds(100))
    
    let lowSeverityError = ClipboardError.invalidInput(message: "低重要度エラー")
    let mediumSeverityError = ClipboardError.operationFailed(operation: "中重要度操作")
    let highSeverityError = ClipboardError.systemFailure(component: "高重要度コンポーネント")
    
    // When
    logger.logError(lowSeverityError, context: "低重要度コンテキスト")
    logger.logError(mediumSeverityError, context: "中重要度コンテキスト")
    logger.logError(highSeverityError, context: "高重要度コンテキスト")
    
    // Then
    let highSeverityErrors = logger.getErrorsBySeverity(.high)
    let mediumSeverityErrors = logger.getErrorsBySeverity(.medium)
    let lowSeverityErrors = logger.getErrorsBySeverity(.low)
    
    #expect(highSeverityErrors.count >= 1)
    #expect(mediumSeverityErrors.count >= 1)
    #expect(lowSeverityErrors.count >= 1)
    
    // 新しく追加された3つのエラーがそれぞれ適切な重要度に分類されていることを確認
    let recentHighErrors = highSeverityErrors.prefix(10)
    let recentMediumErrors = mediumSeverityErrors.prefix(10)
    let recentLowErrors = lowSeverityErrors.prefix(10)
    
    #expect(recentHighErrors.contains { $0.error.errorCode == "CLIPBOARD_SYSTEM_FAILURE" })
    #expect(recentMediumErrors.contains { $0.error.errorCode == "CLIPBOARD_OPERATION_FAILED" })
    #expect(recentLowErrors.contains { $0.error.errorCode == "CLIPBOARD_INVALID_INPUT" })
}

@Test("CrashReporter基本機能テスト")
func testCrashReporterBasicFunctionality() async throws {
    // Given
    let crashReporter = CrashReporter.shared
    let testException = NSException(name: .genericException, reason: "テスト例外", userInfo: nil)
    
    // When
    let crashReport = crashReporter.generateCrashReport(
        exception: testException,
        context: ["operation": "test", "timestamp": Date().timeIntervalSince1970]
    )
    
    // Then
    #expect(crashReport.exception.name == .genericException)
    #expect(crashReport.exception.reason == "テスト例外")
    #expect(crashReport.context["operation"] as? String == "test")
    #expect(crashReport.timestamp.timeIntervalSince1970 > 0)
}

@Test("ErrorRecovery自動復旧テスト")
func testErrorRecoveryAutomaticRecovery() async throws {
    // Given
    let recoveryManager = ErrorRecoveryManager()
    let recoverableError = ClipboardError.temporaryUnavailable(retryAfter: 1.0)
    
    var recoveryAttempted = false
    let recoveryAction: () async -> Bool = {
        recoveryAttempted = true
        return true // 復旧成功をシミュレート
    }
    
    // When
    let result = await recoveryManager.attemptRecovery(
        from: recoverableError,
        using: recoveryAction
    )
    
    // Then
    #expect(result == true)
    #expect(recoveryAttempted == true)
}

@Test("ErrorMetrics統計情報テスト")
func testErrorMetricsStatistics() async throws {
    // Given
    let metrics = ErrorMetrics.shared
    metrics.reset() // テスト前にメトリクスをリセット
    
    let error1 = ClipboardError.networkError(reason: "接続失敗")
    let error2 = ClipboardError.networkError(reason: "タイムアウト")
    let error3 = ClipboardError.dataCorruption(underlyingError: nil)
    
    // When
    metrics.recordError(error1)
    metrics.recordError(error2)
    metrics.recordError(error3)
    
    // Then
    let statistics = metrics.getStatistics()
    #expect(statistics.totalErrors == 3)
    #expect(statistics.errorsByType["CLIPBOARD_NETWORK_ERROR"] == 2)
    #expect(statistics.errorsByType["CLIPBOARD_DATA_CORRUPTION"] == 1)
}

@Test("LogRotation自動ローテーションテスト")
func testLogRotationAutoRotation() async throws {
    // Given
    let logger = ErrorLogger.shared
    logger.clearLogs() // テスト前にログをクリア
    
    // 少し待ってクリアが完了するのを待つ
    try await Task.sleep(for: .milliseconds(100))
    
    let maxLogEntries = 1000 // ErrorLoggerの実際の制限に合わせる
    
    // When - 制限を超えるログエントリを追加
    for i in 0..<1010 {
        let error = ClipboardError.invalidInput(message: "テストエラー \(i)")
        logger.logError(error, context: "ローテーションテスト")
    }
    
    // Then - 古いログが自動的に削除される
    let recentErrors = logger.getRecentErrors(limit: 1100)
    #expect(recentErrors.count <= maxLogEntries)
    
    // 最新のエントリが保持されていることを確認
    #expect(recentErrors.first?.context.contains("ローテーションテスト") == true)
}

@Test("AsyncErrorHandling非同期エラー処理テスト")
func testAsyncErrorHandling() async throws {
    // Given
    let asyncHandler = AsyncErrorHandler()
    var capturedErrors: [ClipboardError] = []
    
    await asyncHandler.setErrorCallback { error in
        capturedErrors.append(error)
    }
    
    // When - 非同期エラーを発生させる
    let error = ClipboardError.operationTimeout(operation: "非同期テスト", timeout: 5.0)
    await asyncHandler.handleError(error)
    
    // Then
    #expect(capturedErrors.count == 1)
    #expect(capturedErrors.first?.errorCode == "CLIPBOARD_OPERATION_TIMEOUT")
}

@Test("ErrorContext詳細コンテキストテスト")
func testErrorContextDetailedContext() async throws {
    // Given
    let context = ErrorContext()
    context.addContext("user_action", "copy_text")
    context.addContext("clipboard_size", 1024)
    context.addContext("memory_pressure", true)
    
    let error = ClipboardError.operationFailed(operation: "テスト操作")
    
    // When
    let enrichedError = context.enrichError(error)
    
    // Then
    #expect(enrichedError.context["user_action"] as? String == "copy_text")
    #expect(enrichedError.context["clipboard_size"] as? Int == 1024)
    #expect(enrichedError.context["memory_pressure"] as? Bool == true)
}