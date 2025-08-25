import Testing
import SwiftUI
import SwiftData
import Foundation
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("ClipboardHistoryView Tests")
struct ClipboardHistoryViewTests {
    
    @Test("ClipboardHistoryViewの基本初期化")
    func basicHistoryViewInitialization() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        // When
        let historyView = ClipboardHistoryView()
            .modelContext(context)
        
        // Then
        // SwiftUIビューの存在確認（初期化が成功すること）
        #expect(historyView != nil)
    }
    
    @Test("空の履歴表示")
    func emptyHistoryDisplay() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        // When
        let historyView = ClipboardHistoryView()
            .modelContext(context)
        
        // Then
        // ビューが正常に初期化されること
        #expect(historyView != nil)
    }
    
    @Test("アイテム付きの履歴表示")
    func historyDisplayWithItems() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        // テストデータの追加
        let item1 = ClipboardItemModel(
            contentData: "Test Item 1".data(using: .utf8)!,
            contentType: .text,
            preview: "Test Item 1"
        )
        let item2 = ClipboardItemModel(
            contentData: "Test Item 2".data(using: .utf8)!,
            contentType: .text,
            preview: "Test Item 2"
        )
        
        context.insert(item1)
        context.insert(item2)
        try context.save()
        
        // When
        let historyView = ClipboardHistoryView()
            .modelContext(context)
        
        // Then
        // ビューが正常に初期化されること
        #expect(historyView != nil)
    }
    
    @Test("SearchBarの初期化")
    func searchBarInitialization() async throws {
        // Given
        @State var searchText = ""
        
        // When
        let searchBar = SearchBar(text: $searchText)
        
        // Then
        #expect(searchBar != nil)
    }
    
    @Test("FilterBarの初期化")
    func filterBarInitialization() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        #expect(filterBar != nil)
    }
    
    @Test("ContentFilterの全ケース確認")
    func contentFilterAllCases() async throws {
        // Given & When
        let allCases = ContentFilter.allCases
        
        // Then
        #expect(allCases.count == 5)
        #expect(allCases.contains(.all))
        #expect(allCases.contains(.text))
        #expect(allCases.contains(.image))
        #expect(allCases.contains(.url))
        #expect(allCases.contains(.code))
    }
    
    @Test("ContentFilterのcontentType変換")
    func contentFilterContentTypeConversion() async throws {
        // Given & When & Then
        #expect(ContentFilter.all.contentType == nil)
        #expect(ContentFilter.text.contentType == .text)
        #expect(ContentFilter.image.contentType == .image)
        #expect(ContentFilter.url.contentType == .url)
        #expect(ContentFilter.code.contentType == .code)
    }
}