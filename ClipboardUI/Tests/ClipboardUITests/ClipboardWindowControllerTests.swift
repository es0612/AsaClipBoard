import Testing
import SwiftUI
@testable import ClipboardUI
import ClipboardCore

@Suite("ClipboardWindowController Tests")
struct ClipboardWindowControllerTests {
    
    @Test("ClipboardWindowControllerの初期化")
    @MainActor func clipboardWindowControllerInitialization() {
        let windowController = ClipboardWindowController()
        
        #expect(windowController.isWindowVisible == false, "初期状態ではウィンドウが非表示")
        #expect(windowController.selectedIndex == 0, "初期状態では最初のアイテムが選択されている")
        #expect(windowController.clipboardItems.isEmpty, "初期状態ではクリップボードアイテムが空")
    }
    
    @Test("ホットキー押下時のウィンドウ表示")
    @MainActor func hotkeyPressedShowsWindow() async {
        let windowController = ClipboardWindowController()
        
        // テストデータの準備
        let testData1 = "テスト1".data(using: .utf8)!
        let testData2 = "テスト2".data(using: .utf8)!
        windowController.clipboardItems = [
            ClipboardItemModel(contentData: testData1, contentType: .text, preview: "テスト1"),
            ClipboardItemModel(contentData: testData2, contentType: .text, preview: "テスト2")
        ]
        
        await windowController.showClipboardWindow()
        
        #expect(windowController.isWindowVisible == true, "ホットキー押下後にウィンドウが表示される")
        #expect(windowController.selectedIndex == 0, "最初のアイテムが選択されている")
    }
    
    @Test("Escキー押下時のウィンドウ非表示")
    @MainActor func escapeKeyHidesWindow() async {
        let windowController = ClipboardWindowController()
        
        // テストデータの準備
        let testData = "テスト".data(using: .utf8)!
        windowController.clipboardItems = [
            ClipboardItemModel(contentData: testData, contentType: .text, preview: "テスト")
        ]
        
        // ウィンドウを表示状態にする
        await windowController.showClipboardWindow()
        #expect(windowController.isWindowVisible == true, "ウィンドウが表示されている")
        
        // Escキーでウィンドウを非表示
        await windowController.hideClipboardWindow()
        
        #expect(windowController.isWindowVisible == false, "Escキー押下後にウィンドウが非表示になる")
    }
    
    @Test("上下キーでのアイテム選択")
    @MainActor func keyboardNavigationSelection() async {
        let windowController = ClipboardWindowController()
        
        // テストデータの準備
        let testData1 = "テスト1".data(using: .utf8)!
        let testData2 = "テスト2".data(using: .utf8)!
        let testData3 = "テスト3".data(using: .utf8)!
        windowController.clipboardItems = [
            ClipboardItemModel(contentData: testData1, contentType: .text, preview: "テスト1"),
            ClipboardItemModel(contentData: testData2, contentType: .text, preview: "テスト2"),
            ClipboardItemModel(contentData: testData3, contentType: .text, preview: "テスト3")
        ]
        
        await windowController.showClipboardWindow()
        
        // 下キーで次のアイテムを選択
        await windowController.selectNext()
        #expect(windowController.selectedIndex == 1, "下キー押下で次のアイテムが選択される")
        
        // さらに下キーで次のアイテムを選択
        await windowController.selectNext()
        #expect(windowController.selectedIndex == 2, "さらに下キー押下で最後のアイテムが選択される")
        
        // 最後のアイテムで下キーを押すと最初に戻る
        await windowController.selectNext()
        #expect(windowController.selectedIndex == 0, "最後のアイテムで下キーを押すと最初に戻る")
        
        // 上キーで前のアイテムを選択
        await windowController.selectPrevious()
        #expect(windowController.selectedIndex == 2, "上キー押下で前のアイテムが選択される")
    }
    
    @Test("Enterキー押下時のアイテム選択と貼り付け")
    @MainActor func enterKeySelectsAndPastesItem() async {
        let windowController = ClipboardWindowController()
        var selectedItem: ClipboardItemModel?
        
        // コールバック設定
        windowController.onItemSelected = { item in
            selectedItem = item
        }
        
        // テストデータの準備
        let testData1 = "テスト1".data(using: .utf8)!
        let testData2 = "テスト2".data(using: .utf8)!
        let testItems = [
            ClipboardItemModel(contentData: testData1, contentType: .text, preview: "テスト1"),
            ClipboardItemModel(contentData: testData2, contentType: .text, preview: "テスト2")
        ]
        windowController.clipboardItems = testItems
        
        await windowController.showClipboardWindow()
        await windowController.selectNext() // インデックス1を選択
        
        // Enterキーでアイテムを選択
        await windowController.selectCurrentItem()
        
        #expect(selectedItem != nil, "アイテムが選択される")
        #expect(selectedItem?.preview == "テスト2", "正しいアイテムが選択される")
        #expect(windowController.isWindowVisible == false, "選択後にウィンドウが非表示になる")
    }
    
    @Test("空のクリップボードアイテム処理")
    @MainActor func emptyClipboardItemsHandling() async {
        let windowController = ClipboardWindowController()
        
        // 空の状態でウィンドウを表示
        await windowController.showClipboardWindow()
        
        #expect(windowController.isWindowVisible == false, "アイテムが空の場合はウィンドウが表示されない")
        
        // キーナビゲーションのテスト
        await windowController.selectNext()
        #expect(windowController.selectedIndex == 0, "空の状態では選択インデックスは0のまま")
        
        await windowController.selectPrevious()
        #expect(windowController.selectedIndex == 0, "空の状態では選択インデックスは0のまま")
    }
}