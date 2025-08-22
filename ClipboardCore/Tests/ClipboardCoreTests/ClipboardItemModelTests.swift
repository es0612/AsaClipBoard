import Testing
import Foundation
import SwiftData
@testable import ClipboardCore

@Suite("ClipboardItemModel Tests")
struct ClipboardItemModelTests {
    
    @Test("ClipboardItemModelの基本的な初期化")
    func basicInitialization() async throws {
        // Given
        let testData = "Test content".data(using: .utf8)!
        let contentType = ClipboardContentType.text
        let preview = "Test content"
        
        // When
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: contentType,
            preview: preview
        )
        
        // Then
        #expect(item.contentData == testData)
        #expect(item.contentType == contentType)
        #expect(item.preview == preview)
        #expect(item.isFavorite == false)
        #expect(item.category == nil)
        #expect(item.isEncrypted == false)
    }
    
    @Test("お気に入り設定の変更")
    func favoriteToggle() async throws {
        // Given
        let testData = "Test content".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .text,
            preview: "Test content"
        )
        
        // When
        item.isFavorite = true
        
        // Then
        #expect(item.isFavorite == true)
    }
    
    @Test("カテゴリの設定")
    func categoryAssignment() async throws {
        // Given
        let testData = "Test content".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .text,
            preview: "Test content"
        )
        
        // When
        item.category = "Work"
        
        // Then
        #expect(item.category == "Work")
    }
}