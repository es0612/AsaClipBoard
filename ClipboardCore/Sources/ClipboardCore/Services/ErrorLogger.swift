import Foundation
import Observation
import OSLog

/// エラーログエントリ
public struct ErrorLogEntry {
    public let error: ClipboardError
    public let context: String
    public let timestamp: Date
    public let threadId: String
    public let severity: ErrorSeverity
    
    public init(error: ClipboardError, context: String) {
        self.error = error
        self.context = context
        self.timestamp = Date()
        self.threadId = Thread.current.name ?? "unknown"
        self.severity = error.severity
    }
}

/// 包括的なエラーロギング機能を提供するサービス
@Observable
public class ErrorLogger {
    public static let shared = ErrorLogger()
    
    private var logEntries: [ErrorLogEntry] = []
    private let maxLogEntries = 1000
    private let logger = Logger(subsystem: "com.clipboardmanager.core", category: "ErrorLogger")
    private let logQueue = DispatchQueue(label: "error.logger.queue", qos: .utility)
    
    private init() {
        // ログローテーションのタイマーを開始
        startLogRotationTimer()
    }
    
    /// エラーをログに記録
    public func logError(_ error: ClipboardError, context: String = "") {
        logQueue.async {
            let entry = ErrorLogEntry(error: error, context: context)
            self.logEntries.insert(entry, at: 0) // 最新のエラーを先頭に追加
            
            // システムログにも記録
            self.logToSystem(entry)
            
            // 最大エントリ数を超えた場合は古いものを削除
            if self.logEntries.count > self.maxLogEntries {
                self.logEntries.removeLast(self.logEntries.count - self.maxLogEntries)
            }
            
            // 重要度が高い場合は即座に処理
            if error.severity == .high {
                self.handleCriticalError(entry)
            }
        }
    }
    
    /// 最近のエラーを取得
    public func getRecentErrors(limit: Int = 50) -> [ErrorLogEntry] {
        return logQueue.sync {
            return Array(logEntries.prefix(limit))
        }
    }
    
    /// 重要度別のエラーを取得
    public func getErrorsBySeverity(_ severity: ErrorSeverity) -> [ErrorLogEntry] {
        return logQueue.sync {
            return logEntries.filter { $0.severity == severity }
        }
    }
    
    /// 特定期間のエラーを取得
    public func getErrorsInRange(from startDate: Date, to endDate: Date) -> [ErrorLogEntry] {
        return logQueue.sync {
            return logEntries.filter { entry in
                entry.timestamp >= startDate && entry.timestamp <= endDate
            }
        }
    }
    
    /// エラータイプ別の統計を取得
    public func getErrorStatistics() -> [String: Int] {
        return logQueue.sync {
            var statistics: [String: Int] = [:]
            for entry in logEntries {
                let errorCode = entry.error.errorCode
                statistics[errorCode, default: 0] += 1
            }
            return statistics
        }
    }
    
    /// ログをクリア
    public func clearLogs() {
        logQueue.async {
            self.logEntries.removeAll()
        }
    }
    
    /// ログをファイルにエクスポート
    public func exportLogs() -> URL? {
        return logQueue.sync {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let filename = "clipboard_errors_\(formatter.string(from: Date())).log"
            
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            
            let fileURL = documentsURL.appendingPathComponent(filename)
            
            let logContent = logEntries.map { entry in
                let timestamp = ISO8601DateFormatter().string(from: entry.timestamp)
                return "[\(timestamp)] [\(entry.severity.rawValue)] [\(entry.threadId)] \(entry.error.errorCode): \(entry.error.localizedDescription)\nContext: \(entry.context)\n"
            }.joined(separator: "\n")
            
            do {
                try logContent.write(to: fileURL, atomically: true, encoding: .utf8)
                return fileURL
            } catch {
                logger.error("Failed to export logs: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func logToSystem(_ entry: ErrorLogEntry) {
        switch entry.severity {
        case .high:
            logger.error("\(entry.error.errorCode): \(entry.error.localizedDescription)")
        case .medium:
            logger.warning("\(entry.error.errorCode): \(entry.error.localizedDescription)")
        case .low:
            logger.info("\(entry.error.errorCode): \(entry.error.localizedDescription)")
        }
    }
    
    private func handleCriticalError(_ entry: ErrorLogEntry) {
        // 重要なエラーの場合は追加的な処理を実行
        logger.critical("Critical error detected: \(entry.error.description)")
        
        // クラッシュレポートの生成（必要に応じて）
        if entry.error.severity == .high {
            CrashReporter.shared.recordError(entry.error, context: entry.context)
        }
    }
    
    private func startLogRotationTimer() {
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in // 1時間ごと
            self.performLogRotation()
        }
    }
    
    private func performLogRotation() {
        logQueue.async {
            // 24時間以上古いログエントリを削除
            let cutoffDate = Date().addingTimeInterval(-24 * 60 * 60)
            self.logEntries.removeAll { $0.timestamp < cutoffDate }
        }
    }
}

/// クラッシュレポート情報
public struct CrashReport {
    public let exception: NSException
    public let context: [String: Any]
    public let timestamp: Date
    public let systemInfo: [String: String]
    
    public init(exception: NSException, context: [String: Any]) {
        self.exception = exception
        self.context = context
        self.timestamp = Date()
        self.systemInfo = [
            "os_version": ProcessInfo.processInfo.operatingSystemVersionString,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "device_model": ProcessInfo.processInfo.machineDescription
        ]
    }
}

/// クラッシュレポート機能を提供するサービス
public class CrashReporter {
    public static let shared = CrashReporter()
    
    private var crashReports: [CrashReport] = []
    private let maxReports = 10
    private let logger = Logger(subsystem: "com.clipboardmanager.core", category: "CrashReporter")
    
    private init() {
        setupExceptionHandler()
    }
    
    /// エラーを記録
    public func recordError(_ error: ClipboardError, context: String) {
        let exception = NSException(
            name: NSExceptionName(error.errorCode),
            reason: error.localizedDescription,
            userInfo: ["context": context]
        )
        
        let crashReport = generateCrashReport(exception: exception, context: ["error_context": context])
        storeCrashReport(crashReport)
    }
    
    /// クラッシュレポートを生成
    public func generateCrashReport(exception: NSException, context: [String: Any]) -> CrashReport {
        return CrashReport(exception: exception, context: context)
    }
    
    /// 最近のクラッシュレポートを取得
    public func getRecentCrashReports() -> [CrashReport] {
        return Array(crashReports.prefix(maxReports))
    }
    
    /// クラッシュレポートをファイルに保存
    public func exportCrashReports() -> URL? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "crash_reports_\(formatter.string(from: Date())).json"
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        do {
            let data = try JSONSerialization.data(withJSONObject: serializeCrashReports(), options: .prettyPrinted)
            try data.write(to: fileURL)
            return fileURL
        } catch {
            logger.error("Failed to export crash reports: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    private func setupExceptionHandler() {
        NSSetUncaughtExceptionHandler { exception in
            CrashReporter.shared.handleUncaughtException(exception)
        }
    }
    
    private func handleUncaughtException(_ exception: NSException) {
        let crashReport = generateCrashReport(exception: exception, context: [:])
        storeCrashReport(crashReport)
        logger.critical("Uncaught exception: \(exception.reason ?? "Unknown")")
    }
    
    private func storeCrashReport(_ crashReport: CrashReport) {
        crashReports.insert(crashReport, at: 0)
        
        // 最大レポート数を超えた場合は古いものを削除
        if crashReports.count > maxReports {
            crashReports.removeLast(crashReports.count - maxReports)
        }
    }
    
    private func serializeCrashReports() -> [[String: Any]] {
        return crashReports.map { report in
            [
                "exception": [
                    "name": report.exception.name.rawValue,
                    "reason": report.exception.reason ?? "",
                    "userInfo": report.exception.userInfo ?? [:]
                ],
                "context": report.context,
                "timestamp": ISO8601DateFormatter().string(from: report.timestamp),
                "systemInfo": report.systemInfo
            ]
        }
    }
}

// ProcessInfo extension for machine description
extension ProcessInfo {
    var machineDescription: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let identifier = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }
        
        return identifier
    }
}