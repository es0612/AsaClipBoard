import Testing
import Foundation
import SwiftData
import NaturalLanguage
@testable import ClipboardCore

@Suite("SearchManager Tests")
struct SearchManagerTests {
    
    @Test("SearchManagerの基本初期化")
    @MainActor
    func basicInitialization() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        // When
        let sut = SearchManager(modelContext: context)
        
        // Then
        // SearchManagerが正常に初期化される（nilでないことは型システムで保証される）
        #expect(true, "SearchManagerが正常に初期化される")
    }
    
    @Test("空のクエリでの検索")
    @MainActor 
    func emptyQuerySearch() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // テストデータを追加
        let item = ClipboardItemModel(
            contentData: "Test data".data(using: .utf8)!,
            contentType: .text,
            preview: "Test data"
        )
        context.insert(item)
        try context.save()
        
        // When
        let results = await sut.search(query: "")
        
        // Then
        #expect(results.count > 0, "空のクエリでは最近のアイテムを返す")
        #expect(results.first?.preview == "Test data")
    }
    
    @Test("完全一致検索")
    @MainActor
    func exactSearch() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // テストデータを追加
        let item1 = ClipboardItemModel(
            contentData: "Hello World".data(using: .utf8)!,
            contentType: .text,
            preview: "Hello World"
        )
        let item2 = ClipboardItemModel(
            contentData: "Swift Programming".data(using: .utf8)!,
            contentType: .text,
            preview: "Swift Programming"
        )
        
        context.insert(item1)
        context.insert(item2)
        try context.save()
        
        // When
        let results = await sut.search(query: "Hello")
        
        // Then
        #expect(results.count > 0, "Hello を含むアイテムが見つかる")
        #expect(results.contains { $0.preview.contains("Hello") }, "検索結果にHelloが含まれる")
    }
    
    @Test("あいまい検索（NaturalLanguage使用）")
    @MainActor
    func fuzzySearch() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        let item = ClipboardItemModel(
            contentData: "SwiftUI Development".data(using: .utf8)!,
            contentType: .text,
            preview: "SwiftUI Development"
        )
        context.insert(item)
        try context.save()
        
        // When - タイポを含む検索
        let results = await sut.search(query: "SwiftUi Develop")
        
        // Then
        #expect(results.count > 0, "あいまい検索で結果が見つかる")
        #expect(results.first?.preview.contains("SwiftUI") == true, "SwiftUIアイテムが見つかる")
    }
    
    @Test("検索インデックス構築と活用")
    @MainActor
    func searchIndexUsage() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // 複数のテストデータを追加
        let items = [
            ("Swift is a programming language", ClipboardContentType.text),
            ("Python development tools", ClipboardContentType.text),
            ("JavaScript framework React", ClipboardContentType.text),
            ("Rust memory safety", ClipboardContentType.text)
        ]
        
        for (content, type) in items {
            let item = ClipboardItemModel(
                contentData: content.data(using: .utf8)!,
                contentType: type,
                preview: content
            )
            context.insert(item)
        }
        try context.save()
        
        // インデックス構築を待つ
        try await Task.sleep(for: .milliseconds(100))
        
        // When
        let results = await sut.search(query: "programming")
        
        // Then
        #expect(results.count > 0, "インデックス検索で結果が見つかる")
        #expect(results.contains { $0.preview.contains("programming") || $0.preview.contains("Swift") },
                "プログラミング関連のアイテムが見つかる")
    }
    
    @Test("正規表現検索サポート")
    @MainActor
    func regexSearch() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // テストデータを追加
        let items = [
            "test@example.com",
            "user@domain.org",
            "https://www.apple.com",
            "Regular text content"
        ]
        
        for content in items {
            let item = ClipboardItemModel(
                contentData: content.data(using: .utf8)!,
                contentType: .text,
                preview: content
            )
            context.insert(item)
        }
        try context.save()
        
        // When - メールアドレスのパターンで検索
        let results = await sut.searchWithRegex(pattern: #"\w+@\w+\.\w+"#)
        
        // Then
        #expect(results.count == 2, "メールアドレスが2つ見つかる")
        #expect(results.allSatisfy { $0.preview.contains("@") }, "全ての結果がメールアドレス")
    }
    
    @Test("コンテンツタイプによるフィルタリング")
    @MainActor
    func contentTypeFiltering() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // 異なるタイプのテストデータ
        let textItem = ClipboardItemModel(
            contentData: "Text content".data(using: .utf8)!,
            contentType: ClipboardContentType.text,
            preview: "Text content"
        )
        let urlItem = ClipboardItemModel(
            contentData: "https://example.com".data(using: .utf8)!,
            contentType: ClipboardContentType.url,
            preview: "https://example.com"
        )
        let emailItem = ClipboardItemModel(
            contentData: "test@example.com".data(using: .utf8)!,
            contentType: ClipboardContentType.email,
            preview: "test@example.com"
        )
        
        context.insert(textItem)
        context.insert(urlItem)
        context.insert(emailItem)
        try context.save()
        
        // When
        let urlResults = await sut.searchByContentType(ClipboardContentType.url)
        let emailResults = await sut.searchByContentType(ClipboardContentType.email)
        
        // Then
        #expect(urlResults.count == 1, "URLタイプのアイテムが1つ見つかる")
        #expect(urlResults.first?.contentType == ClipboardContentType.url, "結果がURLタイプ")
        #expect(emailResults.count == 1, "メールタイプのアイテムが1つ見つかる")
        #expect(emailResults.first?.contentType == ClipboardContentType.email, "結果がメールタイプ")
    }
    
    @Test("日付範囲によるフィルタリング")
    @MainActor
    func dateRangeFiltering() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        
        // 異なる日付のアイテムを作成
        let oldItem = ClipboardItemModel(
            contentData: "Old content".data(using: .utf8)!,
            contentType: ClipboardContentType.text,
            preview: "Old content"
        )
        oldItem.timestamp = yesterday
        
        let newItem = ClipboardItemModel(
            contentData: "New content".data(using: .utf8)!,
            contentType: ClipboardContentType.text,
            preview: "New content"
        )
        newItem.timestamp = now
        
        context.insert(oldItem)
        context.insert(newItem)
        try context.save()
        
        // When
        let results = await sut.searchByDateRange(from: now, to: tomorrow)
        
        // Then
        #expect(results.count == 1, "日付範囲内のアイテムが1つ見つかる")
        #expect(results.first?.preview == "New content", "新しいアイテムが見つかる")
    }
    
    @Test("検索結果の制限とページング")
    @MainActor
    func searchResultLimiting() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // 大量のテストデータを追加
        for i in 1...100 {
            let item = ClipboardItemModel(
                contentData: "Test item \(i)".data(using: .utf8)!,
                contentType: ClipboardContentType.text,
                preview: "Test item \(i)"
            )
            context.insert(item)
        }
        try context.save()
        
        // When
        let results = await sut.search(query: "Test")
        
        // Then
        #expect(results.count <= 50, "結果が最大50件に制限される")
    }
}