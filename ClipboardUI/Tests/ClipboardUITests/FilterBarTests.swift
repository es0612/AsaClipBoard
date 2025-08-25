import Testing
import SwiftUI
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("FilterBar Tests")
struct FilterBarTests {
    
    @Test("FilterBarの基本初期化")
    func basicFilterBarInitialization() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        #expect(filterBar != nil)
    }
    
    @Test("FilterBarのフィルター選択状態")
    func filterBarSelectionState() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .text
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        #expect(filterBar != nil)
        #expect(selectedFilter == .text)
    }
    
    @Test("FilterBarの全フィルターオプション表示")
    func filterBarAllOptionsDisplay() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        let allFilters = ContentFilter.allCases
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        #expect(filterBar != nil)
        #expect(allFilters.count == 5)
        #expect(allFilters.contains(.all))
        #expect(allFilters.contains(.text))
        #expect(allFilters.contains(.image))
        #expect(allFilters.contains(.url))
        #expect(allFilters.contains(.code))
    }
    
    @Test("FilterBarのカスタムフィルターオプション")
    func filterBarCustomFilterOptions() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        let customFilters: [ContentFilter] = [.all, .text, .url]
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter, filters: customFilters)
        
        // Then
        #expect(filterBar != nil)
        #expect(customFilters.count == 3)
    }
    
    @Test("FilterBarのコールバック機能")
    func filterBarCallbackFunctionality() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        var callbackFilter: ContentFilter = .all
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter) { filter in
            callbackFilter = filter
        }
        
        // Then
        #expect(filterBar != nil)
        #expect(callbackFilter == .all)
    }
    
    @Test("FilterBarのアニメーション設定")
    func filterBarAnimationSettings() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .text
        
        // When
        let filterBar = FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        #expect(filterBar != nil)
        #expect(selectedFilter == .text)
    }
}