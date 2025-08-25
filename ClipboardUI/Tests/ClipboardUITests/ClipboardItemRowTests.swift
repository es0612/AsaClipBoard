import Testing
import SwiftUI
import Foundation
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("ClipboardItemRow Tests")
struct ClipboardItemRowTests {
    
    @Test("ClipboardItemRowの基本表示")
    func basicItemRowDisplay() async throws {
        // Given
        let testData = "Test content".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .text,
            preview: "Test content preview"
        )
        
        // When
        let itemRow = ClipboardItemRow(item: item)
        
        // Then
        #expect(itemRow.item.preview == "Test content preview")
        #expect(itemRow.item.contentType == .text)
    }
    
    @Test("お気に入りアイテムの表示")
    func favoriteItemDisplay() async throws {
        // Given
        let testData = "Favorite content".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .text,
            timestamp: Date(),
            isFavorite: true,
            category: nil,
            preview: "Favorite content"
        )
        
        // When
        let itemRow = ClipboardItemRow(item: item)
        
        // Then
        #expect(itemRow.item.isFavorite == true)
    }
}