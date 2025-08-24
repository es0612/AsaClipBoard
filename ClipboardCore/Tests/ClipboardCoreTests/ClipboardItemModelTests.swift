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
    
    @Test("SmartActionとのリレーションシップ")
    func smartActionRelationship() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, SmartActionModel.self, configurations: config)
        let context = ModelContext(container)
        
        let testData = "https://www.apple.com".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .url,
            preview: "https://www.apple.com"
        )
        
        let smartAction = SmartActionModel(
            id: "url_action",
            actionType: "openURL",
            title: "URLを開く",
            systemImage: "safari",
            actionData: testData
        )
        
        // When
        item.smartActions.append(smartAction)
        context.insert(item)
        context.insert(smartAction)
        try context.save()
        
        // Then
        #expect(item.smartActions.count == 1)
        #expect(item.smartActions.first?.title == "URLを開く")
        #expect(smartAction.clipboardItem === item)
    }
    
    @Test("CategoryModelとのリレーションシップ")
    func categoryModelRelationship() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, CategoryModel.self, configurations: config)
        let context = ModelContext(container)
        
        let category = CategoryModel(name: "Work", color: "blue", systemImage: "briefcase")
        let testData = "Work document content".data(using: .utf8)!
        let item = ClipboardItemModel(
            contentData: testData,
            contentType: .text,
            preview: "Work document content"
        )
        
        // When
        item.categoryModel = category
        context.insert(category)
        context.insert(item)
        try context.save()
        
        // Then
        #expect(item.categoryModel?.name == "Work")
        #expect(category.clipboardItems.contains(item) == true)
    }
}