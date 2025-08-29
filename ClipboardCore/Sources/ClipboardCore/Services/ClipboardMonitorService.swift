import Foundation
import SwiftData
import Observation
#if canImport(AppKit)
import AppKit
#endif

/// クリップボードの変更を監視し、履歴を管理するサービス
@Observable
@MainActor
public class ClipboardMonitorService {
    // MARK: - Properties
    #if canImport(AppKit)
    private var pasteboard: NSPasteboard = NSPasteboard.general
    #endif
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let modelContext: ModelContext
    private let maxHistorySize: Int
    
    public private(set) var clipboardItems: [ClipboardItemModel] = []
    public private(set) var isMonitoring: Bool = false
    
    // MARK: - Initialization
    public init(modelContext: ModelContext, maxHistorySize: Int = 1000) {
        self.modelContext = modelContext
        self.maxHistorySize = maxHistorySize
        loadExistingItems()
    }
    
    // MARK: - Public Methods
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                await self.checkForClipboardChanges()
            }
        }
    }
    
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }
    
    public func processClipboardChange() async {
        #if canImport(AppKit)
        await processClipboardContent(from: pasteboard)
        #endif
    }
    
    // MARK: - Private Methods
    private func loadExistingItems() {
        do {
            var descriptor = FetchDescriptor<ClipboardItemModel>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.fetchLimit = maxHistorySize
            clipboardItems = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading existing clipboard items: \(error)")
            clipboardItems = []
        }
    }
    
    private func checkForClipboardChanges() async {
        #if canImport(AppKit)
        let currentChangeCount = pasteboard.changeCount
        if currentChangeCount != lastChangeCount {
            await processClipboardContent(from: pasteboard)
            lastChangeCount = currentChangeCount
        }
        #endif
    }
    
    #if canImport(AppKit)
    private func processClipboardContent(from pasteboard: NSPasteboard) async {
        let newItem = ClipboardItemModel(from: pasteboard)
        
        // 重複チェック - 最新アイテムと同じ内容なら追加しない
        if let lastItem = clipboardItems.first,
           lastItem.contentData == newItem.contentData {
            return
        }
        
        // アイテムを追加
        modelContext.insert(newItem)
        clipboardItems.insert(newItem, at: 0)
        
        // 履歴サイズ制限を適用
        enforceHistoryLimit()
        
        // データベースに保存
        do {
            try modelContext.save()
        } catch {
            print("Error saving clipboard item: \(error)")
        }
    }
    #endif
    
    private func enforceHistoryLimit() {
        while clipboardItems.count > maxHistorySize {
            let oldestItem = clipboardItems.removeLast()
            modelContext.delete(oldestItem)
        }
    }
    
    // MARK: - Test Support
    #if DEBUG
    private var testModeString: String?
    
    public func setTestString(_ string: String) async {
        testModeString = string
        await processTestClipboardContent(string)
    }
    
    private func processTestClipboardContent(_ string: String) async {
        let data = string.data(using: .utf8) ?? Data()
        let contentType = ClipboardContentType.detectContentType(for: string)
        let preview = String(string.prefix(100))
        
        let newItem = ClipboardItemModel(
            contentData: data,
            contentType: contentType,
            preview: preview
        )
        
        // 重複チェック
        if let lastItem = clipboardItems.first,
           lastItem.contentData == newItem.contentData {
            return
        }
        
        // アイテムを追加
        modelContext.insert(newItem)
        clipboardItems.insert(newItem, at: 0)
        
        // 履歴サイズ制限を適用
        enforceHistoryLimit()
        
        // データベースに保存
        do {
            try modelContext.save()
        } catch {
            print("Error saving clipboard item: \(error)")
        }
    }

    
    /// クリップボード変更のシミュレーション（ベンチマーク用）
    /// - Parameter changeCount: シミュレートする変更回数
    /// - Note: このメソッドはベンチマークテスト専用です
    public func simulateClipboardChange(changeCount: Int = 1) async {
        for i in 0..<changeCount {
            let simulatedContent = "Simulated clipboard content \(i) - \(UUID().uuidString)"
            await processTestClipboardContent(simulatedContent)
            
            // 実際の処理をシミュレートするために短時間待機
            try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        }
    }
    #endif
}

