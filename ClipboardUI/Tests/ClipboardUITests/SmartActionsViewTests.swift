import Testing
import SwiftUI
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("SmartActionsView Tests")
struct SmartActionsViewTests {
    
    @Test("URLアイテムのスマートアクション表示")
    func urlSmartActionsDisplay() async throws {
        // Given
        let testData = "https://www.apple.com".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .url,
            preview: "https://www.apple.com"
        )
        
        // When
        let smartActionsView = SmartActionsView(item: item)
        
        // Then
        #expect(smartActionsView.item.contentType == .url)
        #expect(smartActionsView.item.preview == "https://www.apple.com")
    }
    
    @Test("メールアドレスのスマートアクション表示")
    func emailSmartActionsDisplay() async throws {
        // Given
        let testData = "test@example.com".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .email,
            preview: "test@example.com"
        )
        
        // When
        let smartActionsView = SmartActionsView(item: item)
        
        // Then
        #expect(smartActionsView.item.contentType == .email)
        #expect(smartActionsView.item.preview == "test@example.com")
    }
    
    @Test("カラーコードのスマートアクション表示")
    func colorCodeSmartActionsDisplay() async throws {
        // Given
        let testData = "#FF5733".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .colorCode,
            preview: "#FF5733"
        )
        
        // When
        let smartActionsView = SmartActionsView(item: item)
        
        // Then
        #expect(smartActionsView.item.contentType == .colorCode)
        #expect(smartActionsView.item.preview == "#FF5733")
    }
    
    @Test("空のスマートアクション")
    func emptySmartActions() async throws {
        // Given
        let testData = "Plain text".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .text,
            preview: "Plain text"
        )
        
        // When
        let smartActionsView = SmartActionsView(item: item)
        
        // Then
        #expect(smartActionsView.item.contentType == .text)
    }
}