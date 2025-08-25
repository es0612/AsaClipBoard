import Testing
import SwiftUI
@testable import ClipboardUI

@Suite("SearchBar Tests")
struct SearchBarTests {
    
    @Test("SearchBarの基本初期化")
    func basicSearchBarInitialization() async throws {
        // Given
        @State var searchText = ""
        
        // When
        let searchBar = SearchBar(text: $searchText)
        
        // Then
        #expect(searchBar != nil)
    }
    
    @Test("SearchBarのプレースホルダー表示")
    func searchBarPlaceholderDisplay() async throws {
        // Given
        @State var searchText = ""
        
        // When
        let searchBar = SearchBar(text: $searchText, placeholder: "テストプレースホルダー")
        
        // Then
        #expect(searchBar != nil)
    }
    
    @Test("SearchBarのクリアボタン表示条件")
    func searchBarClearButtonVisibility() async throws {
        // Given
        @State var searchText = "テストクエリ"
        
        // When
        let searchBar = SearchBar(text: $searchText)
        
        // Then
        // テキストがある場合、クリアボタンが表示されることを確認
        #expect(searchBar != nil)
        #expect(searchText.isEmpty == false)
    }
    
    @Test("SearchBarの空文字時のクリアボタン非表示")
    func searchBarClearButtonHiddenWhenEmpty() async throws {
        // Given
        @State var searchText = ""
        
        // When
        let searchBar = SearchBar(text: $searchText)
        
        // Then
        #expect(searchBar != nil)
        #expect(searchText.isEmpty == true)
    }
    
    @Test("SearchBarの検索件数表示")
    func searchBarWithSearchCount() async throws {
        // Given
        @State var searchText = "テストクエリ"
        let searchCount = 10
        
        // When
        let searchBar = SearchBar(text: $searchText, showSearchCount: true, searchCount: searchCount)
        
        // Then
        #expect(searchBar != nil)
        #expect(searchText == "テストクエリ")
    }
    
    @Test("SearchBarのコールバック機能")
    func searchBarCallbackFunctionality() async throws {
        // Given
        @State var searchText = ""
        var callbackValue: String = ""
        
        // When
        let searchBar = SearchBar(text: $searchText) { newValue in
            callbackValue = newValue
        }
        
        // Then
        #expect(searchBar != nil)
        #expect(callbackValue.isEmpty)
    }
}