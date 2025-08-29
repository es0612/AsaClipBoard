import Foundation
import Darwin

/// CPU使用率の統計情報を格納する構造体
public struct CPUUsageStats {
    public let averageCPUUsage: Double
    public let maxCPUUsage: Double
    public let minCPUUsage: Double
    public let measurementDuration: TimeInterval
    public let sampleCount: Int
    
    public init(averageCPUUsage: Double, maxCPUUsage: Double, minCPUUsage: Double, measurementDuration: TimeInterval, sampleCount: Int) {
        self.averageCPUUsage = averageCPUUsage
        self.maxCPUUsage = maxCPUUsage
        self.minCPUUsage = minCPUUsage
        self.measurementDuration = measurementDuration
        self.sampleCount = sampleCount
    }
}

/// CPU使用率の監視と測定を行うクラス
@objc public class CPUUsageMonitor: NSObject {
    
    // MARK: - Properties
    
    private var isMonitoring: Bool = false
    private var monitoringTimer: Timer?
    private var startTime: Date?
    private var cpuSamples: [Double] = []
    private var sampleInterval: TimeInterval = 0.1 // 100ms間隔でサンプリング
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// CPU使用率の監視を開始
    /// - Parameter sampleInterval: サンプリング間隔（デフォルト: 0.1秒）
    public func startMonitoring(sampleInterval: TimeInterval = 0.1) {
        guard !isMonitoring else { return }
        
        self.sampleInterval = sampleInterval
        self.isMonitoring = true
        self.startTime = Date()
        self.cpuSamples = []
        
        // 初回サンプル
        if let cpuUsage = getCurrentCPUUsage() {
            cpuSamples.append(cpuUsage)
        }
        
        // タイマーで定期的にサンプリング
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { [weak self] _ in
            self?.sampleCPUUsage()
        }
    }
    
    /// CPU使用率の監視を停止し、統計情報を取得
    /// - Returns: CPU使用率の統計情報
    public func stopMonitoringAndGetStats() -> CPUUsageStats {
        isMonitoring = false
        monitoringTimer?.invalidate()
        monitoringTimer = nil
        
        let endTime = Date()
        let duration = startTime.map { endTime.timeIntervalSince($0) } ?? 0
        
        guard !cpuSamples.isEmpty else {
            return CPUUsageStats(
                averageCPUUsage: 0,
                maxCPUUsage: 0,
                minCPUUsage: 0,
                measurementDuration: duration,
                sampleCount: 0
            )
        }
        
        let averageCPU = cpuSamples.reduce(0, +) / Double(cpuSamples.count)
        let maxCPU = cpuSamples.max() ?? 0
        let minCPU = cpuSamples.min() ?? 0
        
        return CPUUsageStats(
            averageCPUUsage: averageCPU,
            maxCPUUsage: maxCPU,
            minCPUUsage: minCPU,
            measurementDuration: duration,
            sampleCount: cpuSamples.count
        )
    }
    
    /// 現在のCPU使用率を取得（即座に）
    /// - Returns: CPU使用率（0-100の範囲）
    public func getCurrentCPUUsage() -> Double? {
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
        
        guard kerr == KERN_SUCCESS else { return nil }
        
        // システムのCPU使用率を取得
        return getSystemCPUUsage()
    }
    
    // MARK: - Private Methods
    
    private func sampleCPUUsage() {
        if let cpuUsage = getCurrentCPUUsage() {
            cpuSamples.append(cpuUsage)
        }
    }
    
    private func getSystemCPUUsage() -> Double {
        var cpuInfo: processor_info_array_t!
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCpus: natural_t = 0
        
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &numCpus,
                                       &cpuInfo,
                                       &numCpuInfo)
        
        guard result == KERN_SUCCESS else {
            // エラー時は0を返す
            return 0.0
        }
        
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), vm_size_t(numCpuInfo))
        }
        
        let cpuLoadInfo = UnsafeBufferPointer<processor_cpu_load_info>(
            start: UnsafePointer(OpaquePointer(cpuInfo)),
            count: Int(numCpus)
        )
        
        var totalUser: UInt32 = 0
        var totalSystem: UInt32 = 0
        var totalIdle: UInt32 = 0
        var totalNice: UInt32 = 0
        
        for cpu in cpuLoadInfo {
            totalUser += cpu.cpu_ticks.0    // CPU_STATE_USER
            totalSystem += cpu.cpu_ticks.1  // CPU_STATE_SYSTEM
            totalIdle += cpu.cpu_ticks.2    // CPU_STATE_IDLE
            totalNice += cpu.cpu_ticks.3    // CPU_STATE_NICE
        }
        
        let totalTicks = totalUser + totalSystem + totalIdle + totalNice
        guard totalTicks > 0 else { return 0.0 }
        
        let activeTicks = totalUser + totalSystem + totalNice
        let cpuUsage = (Double(activeTicks) / Double(totalTicks)) * 100.0
        
        return cpuUsage
    }
}

// MARK: - CPU Benchmark Utilities

extension CPUUsageMonitor {
    
    /// 指定された処理のCPU使用率を測定
    /// - Parameters:
    ///   - duration: 測定期間
    ///   - work: 測定対象の処理
    /// - Returns: CPU使用率統計
    public func measureCPUUsage<T>(duration: TimeInterval, work: @escaping () async throws -> T) async rethrows -> (result: T, stats: CPUUsageStats) {
        startMonitoring()
        
        let result = try await work()
        
        // 指定された期間まで待機
        let remainingTime = duration - (Date().timeIntervalSince(startTime ?? Date()))
        if remainingTime > 0 {
            do {
                try await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
            } catch {
                // スリープエラーは無視
            }
        }
        
        let stats = stopMonitoringAndGetStats()
        return (result, stats)
    }
    
    /// 同期処理のCPU使用率を測定
    /// - Parameters:
    ///   - duration: 測定期間
    ///   - work: 測定対象の処理
    /// - Returns: CPU使用率統計
    public func measureCPUUsage<T>(duration: TimeInterval, work: @escaping () throws -> T) throws -> (result: T, stats: CPUUsageStats) {
        startMonitoring()
        
        let result = try work()
        
        // 指定された期間まで待機
        let remainingTime = duration - (Date().timeIntervalSince(startTime ?? Date()))
        if remainingTime > 0 {
            Thread.sleep(forTimeInterval: remainingTime)
        }
        
        let stats = stopMonitoringAndGetStats()
        return (result, stats)
    }
}