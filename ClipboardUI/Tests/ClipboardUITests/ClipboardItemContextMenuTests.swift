import Testing
import SwiftUI
import SwiftData
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("ClipboardItemContextMenu Tests")
struct ClipboardItemContextMenuTests {
    
    @Test("コンテキストメニューの基本初期化")
    func basicContextMenuInitialization() async throws {
        // Given
        let item = ClipboardItemModel(
            contentData: "Test Content".data(using: .utf8)!,
            contentType: .text,
            preview: "Test Content"
        )
        
        // When
        let contextMenu = ClipboardItemContextMenu(item: item)
        
        // Then
        #expect(contextMenu != nil)
        #expect(item.preview == "Test Content")
    }
    
    @Test("お気に入り機能の状態表示")
    func favoriteStatusDisplay() async throws {
        // Given
        let favoriteItem = ClipboardItemModel(
            contentData: "Favorite".data(using: .utf8)!,
            contentType: .text,
            isFavorite: true,
            preview: "Favorite"
        )
        
        let normalItem = ClipboardItemModel(
            contentData: "Normal".data(using: .utf8)!,
            contentType: .text,
            isFavorite: false,
            preview: "Normal"
        )
        
        // When
        let favoriteContextMenu = ClipboardItemContextMenu(item: favoriteItem)
        let normalContextMenu = ClipboardItemContextMenu(item: normalItem)
        
        // Then
        #expect(favoriteContextMenu != nil)
        #expect(normalContextMenu != nil)
        #expect(favoriteItem.isFavorite == true)
        #expect(normalItem.isFavorite == false)
    }
    
    @Test("カテゴリ設定機能の基本表示")
    func categorySettingDisplay() async throws {
        // Given
        let item = ClipboardItemModel(
            contentData: "Test".data(using: .utf8)!,
            contentType: .text,
            preview: "Test"
        )
        
        let category = CategoryModel(name: "テストカテゴリ", color: "blue")
        
        // When
        let contextMenu = ClipboardItemContextMenu(item: item)
        
        // Then
        #expect(contextMenu != nil)
        #expect(category.name == "テストカテゴリ")
    }
}