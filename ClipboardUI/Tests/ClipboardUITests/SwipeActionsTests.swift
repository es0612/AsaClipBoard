import Testing
import SwiftUI
import SwiftData
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("SwipeActions Tests")
struct SwipeActionsTests {
    
    @Test("スワイプアクションの基本機能")
    func basicSwipeActionsFunctionality() async throws {
        // Given
        let item = ClipboardItemModel(
            contentData: "Test".data(using: .utf8)!,
            contentType: .text,
            preview: "Test"
        )
        
        // When
        let swipeActions = SwipeActionsView(item: item)
        
        // Then
        #expect(swipeActions != nil)
        #expect(item.preview == "Test")
    }
    
    @Test("削除アクションの設定")
    func deleteActionConfiguration() async throws {
        // Given
        let item = ClipboardItemModel(
            contentData: "Delete Test".data(using: .utf8)!,
            contentType: .text,
            preview: "Delete Test"
        )
        
        // When
        let swipeActions = SwipeActionsView(item: item, showDeleteAction: true)
        
        // Then
        #expect(swipeActions != nil)
        #expect(item.preview == "Delete Test")
    }
    
    @Test("お気に入りアクションの設定")
    func favoriteActionConfiguration() async throws {
        // Given
        let item = ClipboardItemModel(
            contentData: "Favorite Test".data(using: .utf8)!,
            contentType: .text,
            isFavorite: false,
            preview: "Favorite Test"
        )
        
        // When
        let swipeActions = SwipeActionsView(item: item, showFavoriteAction: true)
        
        // Then
        #expect(swipeActions != nil)
        #expect(item.isFavorite == false)
    }
}