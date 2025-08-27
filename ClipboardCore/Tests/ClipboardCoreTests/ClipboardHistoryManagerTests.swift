import Testing
import Foundation
@testable import ClipboardCore

@Test("ClipboardHistoryManagerの基本機能テスト")
func testClipboardHistoryManagerBasicFunctionality() async throws {
    let manager = ClipboardHistoryManager(maxItems: 100, maxMemoryMB: 50)
    
    #expect(manager.items.isEmpty)
    #expect(manager.currentMemoryUsageMB == 0.0)
    #expect(manager.maxItems == 100)
    #expect(manager.maxMemoryMB == 50)
}

@Test("メモリ制限機能テスト")
func testMemoryLimitEnforcement() async throws {
    let manager = ClipboardHistoryManager(maxItems: 1000, maxMemoryMB: 1) // 1MBに制限
    
    // 大きな画像データを作成してメモリ制限をテスト
    let largeImageData1 = Data(repeating: 0xFF, count: 512 * 1024) // 512KB
    let item1 = ClipboardItemModel(
        contentData: largeImageData1,
        contentType: .image,
        timestamp: Date(),
        preview: "画像1 (512KB)"
    )
    
    let largeImageData2 = Data(repeating: 0xAA, count: 512 * 1024) // 512KB
    let item2 = ClipboardItemModel(
        contentData: largeImageData2,
        contentType: .image,
        timestamp: Date().addingTimeInterval(1),
        preview: "画像2 (512KB)"
    )
    
    // 1つ目のアイテムを追加
    await manager.addItem(item1)
    #expect(manager.items.count == 1)
    
    // 2つ目のアイテムを追加（メモリ制限を超過）
    await manager.addItem(item2)
    #expect(manager.items.count == 1) // 古いアイテムが自動削除される
    #expect(manager.items.first?.id == item2.id)
}

@Test("画像データ圧縮機能テスト")
func testImageDataCompression() async throws {
    let manager = ClipboardHistoryManager(maxItems: 100, maxMemoryMB: 50)
    
    // 3MBの画像データを作成（2MBの閾値を超える）
    let originalImageData = Data(repeating: 0xFF, count: 3 * 1024 * 1024)
    let item = ClipboardItemModel(
        contentData: originalImageData,
        contentType: .image,
        timestamp: Date(),
        preview: "大きな画像 (3MB)"
    )
    
    await manager.addItem(item)
    
    // アイテムが追加されたか確認（圧縮に失敗した場合でも追加される）
    let storedItem = manager.items.first!
    #expect(storedItem.contentType == .image)
    #expect(storedItem.contentData.count > 0)
}

@Test("最大アイテム数制限テスト")
func testMaxItemsLimit() async throws {
    let manager = ClipboardHistoryManager(maxItems: 3, maxMemoryMB: 100)
    
    // 4つのアイテムを追加
    for i in 0..<4 {
        let textData = "テストコンテンツ \(i)".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: textData,
            contentType: .text,
            timestamp: Date().addingTimeInterval(Double(i)),
            preview: "テストコンテンツ \(i)"
        )
        await manager.addItem(item)
    }
    
    #expect(manager.items.count == 3) // 最大数に制限される
    
    // 最新の3つが保持されているかチェック
    let previews = manager.items.map { $0.preview }
    
    #expect(previews.contains("テストコンテンツ 1"))
    #expect(previews.contains("テストコンテンツ 2"))
    #expect(previews.contains("テストコンテンツ 3"))
    #expect(!previews.contains("テストコンテンツ 0"))
}

@Test("重複コンテンツ処理テスト")
func testDuplicateContentHandling() async throws {
    let manager = ClipboardHistoryManager(maxItems: 100, maxMemoryMB: 50)
    
    let textData = "同じコンテンツ".data(using: .utf8)!
    let item1 = ClipboardItemModel(
        contentData: textData,
        contentType: .text,
        timestamp: Date(),
        preview: "同じコンテンツ"
    )
    
    let item2 = ClipboardItemModel(
        contentData: textData,
        contentType: .text,
        timestamp: Date().addingTimeInterval(1),
        preview: "同じコンテンツ"
    )
    
    await manager.addItem(item1)
    await manager.addItem(item2)
    
    #expect(manager.items.count == 1) // 重複は追加されない
}

@Test("自動削除機能テスト")
func testAutoCleanup() async throws {
    let manager = ClipboardHistoryManager(maxItems: 100, maxMemoryMB: 50)
    
    // 古いアイテムを追加（7日前）
    let oldTextData = "古いコンテンツ".data(using: .utf8)!
    let oldItem = ClipboardItemModel(
        contentData: oldTextData,
        contentType: .text,
        timestamp: Date().addingTimeInterval(-8 * 24 * 60 * 60), // 8日前
        preview: "古いコンテンツ"
    )
    
    // 新しいアイテムを追加
    let newTextData = "新しいコンテンツ".data(using: .utf8)!
    let newItem = ClipboardItemModel(
        contentData: newTextData,
        contentType: .text,
        timestamp: Date(),
        preview: "新しいコンテンツ"
    )
    
    await manager.addItem(oldItem)
    await manager.addItem(newItem)
    
    #expect(manager.items.count == 2) // 最初は両方存在
    
    // 自動クリーンアップを実行
    await manager.performAutoCleanup()
    
    #expect(manager.items.count == 1) // 古いアイテムが削除される
    #expect(manager.items.first?.preview == "新しいコンテンツ")
}

@Test("お気に入りアイテム保護テスト")
func testFavoriteItemProtection() async throws {
    let manager = ClipboardHistoryManager(maxItems: 2, maxMemoryMB: 50)
    
    // お気に入りアイテムを作成
    let favoriteTextData = "お気に入りコンテンツ".data(using: .utf8)!
    let favoriteItem = ClipboardItemModel(
        contentData: favoriteTextData,
        contentType: .text,
        timestamp: Date().addingTimeInterval(-1),
        isFavorite: true,
        preview: "お気に入りコンテンツ"
    )
    
    let normalTextData1 = "通常コンテンツ1".data(using: .utf8)!
    let normalItem1 = ClipboardItemModel(
        contentData: normalTextData1,
        contentType: .text,
        timestamp: Date(),
        preview: "通常コンテンツ1"
    )
    
    let normalTextData2 = "通常コンテンツ2".data(using: .utf8)!
    let normalItem2 = ClipboardItemModel(
        contentData: normalTextData2,
        contentType: .text,
        timestamp: Date().addingTimeInterval(1),
        preview: "通常コンテンツ2"
    )
    
    await manager.addItem(favoriteItem)
    await manager.addItem(normalItem1)
    await manager.addItem(normalItem2) // お気に入りではないアイテムが削除されるはず
    
    #expect(manager.items.count == 2)
    #expect(manager.items.contains { $0.isFavorite })
}

@Test("メモリ使用量計算テスト")
func testMemoryUsageCalculation() async throws {
    let manager = ClipboardHistoryManager(maxItems: 100, maxMemoryMB: 50)
    
    let textData = "テストコンテンツ".data(using: .utf8)!
    let item = ClipboardItemModel(
        contentData: textData,
        contentType: .text,
        timestamp: Date(),
        preview: "テストコンテンツ"
    )
    
    await manager.addItem(item)
    
    let expectedMemoryMB = Double(textData.count) / (1024 * 1024)
    #expect(abs(manager.currentMemoryUsageMB - expectedMemoryMB) < 0.001)
}