import Foundation
import Darwin

/// システムパフォーマンスの監視と測定を行うクラス
@objc public class PerformanceMonitor: NSObject {
    
    // MARK: - Singleton
    
    public static let shared = PerformanceMonitor()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Memory Monitoring
    
    /// 現在のメモリ使用量を取得（バイト単位）
    /// - Returns: メモリ使用量（バイト）
    public func getCurrentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            // エラーが発生した場合は0を返す
            return 0
        }
    }
    
    /// 現在のメモリ使用量を取得（MB単位）
    /// - Returns: メモリ使用量（MB）
    public func getCurrentMemoryUsageMB() -> Double {
        let bytesUsed = getCurrentMemoryUsage()
        return Double(bytesUsed) / (1024.0 * 1024.0)
    }
    
    /// メモリ使用量の測定を開始
    /// - Returns: 測定開始時のメモリ使用量（バイト）
    public func startMemoryMeasurement() -> UInt64 {
        return getCurrentMemoryUsage()
    }
    
    /// メモリ使用量の測定を停止し、増加量を計算
    /// - Parameter startMemory: 測定開始時のメモリ使用量
    /// - Returns: メモリ増加量（バイト）
    public func stopMemoryMeasurement(startMemory: UInt64) -> Int64 {
        let currentMemory = getCurrentMemoryUsage()
        return Int64(currentMemory) - Int64(startMemory)
    }
    
    // MARK: - Performance Utilities
    
    /// 指定されたブロックの実行時間を測定
    /// - Parameter block: 測定対象のブロック
    /// - Returns: 実行時間（秒）
    public func measureExecutionTime<T>(_ block: () throws -> T) rethrows -> (result: T, executionTime: TimeInterval) {
        let startTime = Date()
        let result = try block()
        let executionTime = Date().timeIntervalSince(startTime)
        return (result, executionTime)
    }
    
    /// 非同期ブロックの実行時間を測定
    /// - Parameter block: 測定対象の非同期ブロック
    /// - Returns: 実行時間と結果
    public func measureExecutionTime<T>(_ block: () async throws -> T) async rethrows -> (result: T, executionTime: TimeInterval) {
        let startTime = Date()
        let result = try await block()
        let executionTime = Date().timeIntervalSince(startTime)
        return (result, executionTime)
    }
    
    // MARK: - System Information
    
    /// システムの総メモリ量を取得（バイト単位）
    /// - Returns: 総メモリ量（バイト）
    public func getTotalSystemMemory() -> UInt64 {
        var size = UInt64(0)
        var sizeOfSize = size_t(MemoryLayout<UInt64>.size)
        let result = sysctlbyname("hw.memsize", &size, &sizeOfSize, nil, 0)
        
        return result == 0 ? size : 0
    }
    
    /// システムの総メモリ量を取得（MB単位）
    /// - Returns: 総メモリ量（MB）
    public func getTotalSystemMemoryMB() -> Double {
        let totalBytes = getTotalSystemMemory()
        return Double(totalBytes) / (1024.0 * 1024.0)
    }
}

// MARK: - Memory Measurement

/// メモリ使用量の測定結果を格納する構造体
public struct MemoryMeasurement {
    public let startMemoryMB: Double
    public let endMemoryMB: Double
    public let memoryIncreaseMB: Double
    public let executionTime: TimeInterval
    
    public init(startMemoryMB: Double, endMemoryMB: Double, executionTime: TimeInterval) {
        self.startMemoryMB = startMemoryMB
        self.endMemoryMB = endMemoryMB
        self.memoryIncreaseMB = endMemoryMB - startMemoryMB
        self.executionTime = executionTime
    }
    
    /// メモリ成長率を計算（1.0 = 100%）
    public var memoryGrowthRate: Double {
        guard startMemoryMB > 0 else { return 0 }
        return endMemoryMB / startMemoryMB
    }
}