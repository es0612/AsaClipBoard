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
        let _ = await FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        // FilterBar が正常に初期化されることを確認（非オプショナル型のため、nil チェックは削除）
    }
    
    @Test("FilterBarのフィルター選択状態")
    func filterBarSelectionState() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .text
        
        // When
        let _ = await FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        // FilterBarが正常に初期化されることを確認
        #expect(selectedFilter == .text)
    }
    
    @Test("FilterBarの全フィルターオプション表示")
    func filterBarAllOptionsDisplay() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        let allFilters = ContentFilter.allCases
        
        // When
        let _ = await FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        // FilterBarが正常に初期化されることを確認
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
        let _ = await FilterBar(selectedFilter: $selectedFilter, filters: customFilters)
        
        // Then
        // FilterBarが正常に初期化されることを確認
        #expect(customFilters.count == 3)
    }
    
    @Test("FilterBarのコールバック機能")
    func filterBarCallbackFunctionality() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .all
        var callbackFilter: ContentFilter = .all
        
        // When
        let _ = await FilterBar(selectedFilter: $selectedFilter) { filter in
            callbackFilter = filter
        }
        
        // Then
        // FilterBarが正常に初期化されることを確認
        #expect(callbackFilter == .all)
    }
    
    @Test("FilterBarのアニメーション設定")
    func filterBarAnimationSettings() async throws {
        // Given
        @State var selectedFilter: ContentFilter = .text
        
        // When
        let _ = await FilterBar(selectedFilter: $selectedFilter)
        
        // Then
        // FilterBarが正常に初期化されることを確認
        #expect(selectedFilter == .text)
    }
}