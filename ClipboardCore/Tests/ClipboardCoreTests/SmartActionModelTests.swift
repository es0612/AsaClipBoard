import Testing
import Foundation
import SwiftData
@testable import ClipboardCore

@Suite("SmartActionModel Tests")
struct SmartActionModelTests {
    
    @Test("SmartActionModelの基本的な初期化")
    func basicInitialization() async throws {
        // Given
        let id = "test_action"
        let actionType = "openURL"
        let title = "URLを開く"
        let systemImage = "safari"
        let actionData = "https://www.apple.com".data(using: .utf8)!
        
        // When
        let smartAction = SmartActionModel(
            id: id,
            actionType: actionType,
            title: title,
            systemImage: systemImage,
            actionData: actionData
        )
        
        // Then
        #expect(smartAction.id == id)
        #expect(smartAction.actionType == actionType)
        #expect(smartAction.title == title)
        #expect(smartAction.systemImage == systemImage)
        #expect(smartAction.actionData == actionData)
        #expect(smartAction.clipboardItem == nil)
    }
    
    @Test("SwiftDataモデルとして保存・取得")
    func swiftDataPersistence() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: SmartActionModel.self, configurations: config)
        let context = ModelContext(container)
        
        let smartAction = SmartActionModel(
            id: "persist_test",
            actionType: "composeEmail",
            title: "メールを作成",
            systemImage: "envelope",
            actionData: "test@example.com".data(using: .utf8)!
        )
        
        // When
        context.insert(smartAction)
        try context.save()
        
        let descriptor = FetchDescriptor<SmartActionModel>(
            predicate: #Predicate { $0.id == "persist_test" }
        )
        let fetchedActions = try context.fetch(descriptor)
        
        // Then
        #expect(fetchedActions.count == 1)
        #expect(fetchedActions.first?.title == "メールを作成")
    }
}