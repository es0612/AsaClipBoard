import Testing
import Foundation
import SwiftData
@testable import ClipboardCore

@Suite("CategoryModel Tests")
struct CategoryModelTests {
    
    @Test("CategoryModelの基本的な初期化")
    func basicInitialization() async throws {
        // Given
        let name = "Work"
        let color = "blue"
        let systemImage = "briefcase"
        let createdAt = Date()
        
        // When
        let category = CategoryModel(
            name: name,
            color: color,
            systemImage: systemImage,
            createdAt: createdAt
        )
        
        // Then
        #expect(category.name == name)
        #expect(category.color == color)
        #expect(category.systemImage == systemImage)
        #expect(category.createdAt == createdAt)
        #expect(category.clipboardItems.isEmpty == true)
    }
    
    @Test("デフォルト値での初期化")
    func initializationWithDefaults() async throws {
        // Given & When
        let category = CategoryModel(name: "Personal")
        
        // Then
        #expect(category.name == "Personal")
        #expect(category.color == "blue")
        #expect(category.systemImage == "folder")
        #expect(category.createdAt <= Date())
    }
    
    @Test("SwiftDataモデルとして保存・取得")
    func swiftDataPersistence() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CategoryModel.self, configurations: config)
        let context = ModelContext(container)
        
        let category = CategoryModel(name: "Development", color: "green", systemImage: "hammer")
        
        // When
        context.insert(category)
        try context.save()
        
        let descriptor = FetchDescriptor<CategoryModel>(
            predicate: #Predicate { $0.name == "Development" }
        )
        let fetchedCategories = try context.fetch(descriptor)
        
        // Then
        #expect(fetchedCategories.count == 1)
        #expect(fetchedCategories.first?.color == "green")
        #expect(fetchedCategories.first?.systemImage == "hammer")
    }
    
    @Test("複数のクリップボードアイテムとのリレーションシップ")
    func multipleClipboardItemsRelationship() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CategoryModel.self, ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let category = CategoryModel(name: "Code Snippets", color: "purple", systemImage: "chevron.left.forwardslash.chevron.right")
        
        let item1 = ClipboardItemModel(
            contentData: "func hello() {}".data(using: .utf8)!,
            contentType: .code,
            preview: "func hello() {}"
        )
        
        let item2 = ClipboardItemModel(
            contentData: "class MyClass {}".data(using: .utf8)!,
            contentType: .code,
            preview: "class MyClass {}"
        )
        
        // When
        item1.categoryModel = category
        item2.categoryModel = category
        
        context.insert(category)
        context.insert(item1)
        context.insert(item2)
        try context.save()
        
        // Then
        #expect(category.clipboardItems.count == 2)
        #expect(category.clipboardItems.contains(item1) == true)
        #expect(category.clipboardItems.contains(item2) == true)
        #expect(item1.categoryModel === category)
        #expect(item2.categoryModel === category)
    }
}