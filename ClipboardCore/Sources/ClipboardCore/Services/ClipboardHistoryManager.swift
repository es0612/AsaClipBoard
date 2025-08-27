import Foundation
import Observation
import UniformTypeIdentifiers
import ImageIO
import CoreGraphics

@Observable
public final class ClipboardHistoryManager {
    
    public private(set) var items: [ClipboardItemModel] = []
    public let maxItems: Int
    public let maxMemoryMB: Double
    
    public var currentMemoryUsageMB: Double {
        items.reduce(0.0) { total, item in
            total + calculateMemoryUsage(for: item)
        }
    }
    
    private let compressionQueue = DispatchQueue(label: "clipboard.compression", qos: .utility)
    private let cleanupInterval: TimeInterval = 24 * 60 * 60 // 24時間
    private var lastCleanupTime = Date()
    
    public init(maxItems: Int = 1000, maxMemoryMB: Double = 100.0) {
        self.maxItems = maxItems
        self.maxMemoryMB = maxMemoryMB
        
        // 定期的な自動クリーンアップを開始
        Task {
            await startAutoCleanupTimer()
        }
    }
    
    public func addItem(_ item: ClipboardItemModel) async {
        // 重複チェック
        if isDuplicate(item) {
            return
        }
        
        // 画像データの圧縮処理
        let processedItem = await processImageCompression(item)
        
        // メモリ制限チェック前にアイテムを一時追加
        items.insert(processedItem, at: 0)
        
        // メモリ制限の確認と調整
        await enforceMemoryLimit()
        
        // アイテム数制限の確認と調整
        enforceItemLimit()
        
        // 定期クリーンアップが必要かチェック
        if Date().timeIntervalSince(lastCleanupTime) > cleanupInterval {
            await performAutoCleanup()
        }
    }
    
    public func removeItem(_ item: ClipboardItemModel) {
        items.removeAll { $0.id == item.id }
    }
    
    public func removeItems(at indices: IndexSet) {
        for index in indices.sorted(by: >) {
            if index < items.count {
                items.remove(at: index)
            }
        }
    }
    
    public func toggleFavorite(for item: ClipboardItemModel) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isFavorite.toggle()
        }
    }
    
    public func performAutoCleanup() async {
        let cutoffDate = Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7日前
        
        // お気に入りでない古いアイテムを削除
        items.removeAll { item in
            !item.isFavorite && item.timestamp < cutoffDate
        }
        
        lastCleanupTime = Date()
    }
    
    // MARK: - Private Methods
    
    private func isDuplicate(_ newItem: ClipboardItemModel) -> Bool {
        return items.contains { existingItem in
            existingItem.contentType == newItem.contentType && 
            existingItem.contentData == newItem.contentData
        }
    }
    
    private func processImageCompression(_ item: ClipboardItemModel) async -> ClipboardItemModel {
        guard item.contentType == .image else {
            return item
        }
        
        // 画像が大きすぎる場合は圧縮
        let maxImageSize = 2 * 1024 * 1024 // 2MB
        if item.contentData.count > maxImageSize {
            let compressedData = await compressImageData(item.contentData)
            
            // 新しいアイテムを作成（SwiftDataモデルなので直接変更はしない）
            return ClipboardItemModel(
                id: item.id,
                contentData: compressedData,
                contentType: item.contentType,
                timestamp: item.timestamp,
                isFavorite: item.isFavorite,
                category: item.category,
                preview: item.preview,
                isEncrypted: item.isEncrypted
            )
        }
        
        return item
    }
    
    private func compressImageData(_ imageData: Data) async -> Data {
        return await withCheckedContinuation { continuation in
            compressionQueue.async {
                guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
                      let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
                    continuation.resume(returning: imageData)
                    return
                }
                
                let mutableData = NSMutableData()
                guard let destination = CGImageDestinationCreateWithData(
                    mutableData,
                    UTType.jpeg.identifier as CFString,
                    1,
                    nil
                ) else {
                    continuation.resume(returning: imageData)
                    return
                }
                
                let compressionOptions: [CFString: Any] = [
                    kCGImageDestinationLossyCompressionQuality: 0.7
                ]
                
                CGImageDestinationAddImage(destination, image, compressionOptions as CFDictionary)
                CGImageDestinationFinalize(destination)
                
                continuation.resume(returning: mutableData as Data)
            }
        }
    }
    
    private func enforceMemoryLimit() async {
        while currentMemoryUsageMB >= maxMemoryMB && !items.isEmpty {
            // お気に入りでない最も古いアイテムを削除
            if let indexToRemove = items.lastIndex(where: { !$0.isFavorite }) {
                items.remove(at: indexToRemove)
            } else {
                // すべてがお気に入りの場合は最も古いものを削除
                items.removeLast()
            }
        }
    }
    
    private func enforceItemLimit() {
        while items.count > maxItems {
            // お気に入りでない最も古いアイテムを削除
            if let indexToRemove = items.lastIndex(where: { !$0.isFavorite }) {
                items.remove(at: indexToRemove)
            } else {
                // すべてがお気に入りの場合は最も古いものを削除
                items.removeLast()
            }
        }
    }
    
    private func calculateMemoryUsage(for item: ClipboardItemModel) -> Double {
        return Double(item.contentData.count) / (1024 * 1024) // MB単位で返す
    }
    
    private func startAutoCleanupTimer() async {
        while true {
            try? await Task.sleep(for: .seconds(cleanupInterval))
            await performAutoCleanup()
        }
    }
}

// MARK: - Extensions for Search and Filtering

extension ClipboardHistoryManager {
    public func search(query: String) -> [ClipboardItemModel] {
        guard !query.isEmpty else { return items }
        
        return items.filter { item in
            // プレビューテキストで検索
            item.preview.localizedCaseInsensitiveContains(query) ||
            // テキストコンテンツの場合はデータを文字列に変換して検索
            (item.contentType == .text && 
             String(data: item.contentData, encoding: .utf8)?.localizedCaseInsensitiveContains(query) == true)
        }
    }
    
    public func filterBy(contentType: ClipboardContentType) -> [ClipboardItemModel] {
        return items.filter { item in
            item.contentType == contentType
        }
    }
    
    public func filterBy(isFavorite: Bool) -> [ClipboardItemModel] {
        return items.filter { $0.isFavorite == isFavorite }
    }
    
    public func filterBy(category: CategoryModel?) -> [ClipboardItemModel] {
        if let category = category {
            return items.filter { $0.categoryModel?.name == category.name }
        } else {
            return items.filter { $0.categoryModel == nil }
        }
    }
}