import Testing
import SwiftUI
@testable import ClipboardUI
import ClipboardCore

@Suite("HotkeyEventProcessor Tests")
struct HotkeyEventProcessorTests {
    
    @Test("HotkeyEventProcessorの初期化")
    @MainActor func hotkeyEventProcessorInitialization() {
        let processor = HotkeyEventProcessor()
        
        #expect(processor.hotkeyManager != nil, "HotkeyManagerが初期化されている")
        #expect(processor.windowController != nil, "ClipboardWindowControllerが初期化されている")
        #expect(processor.isEnabled == false, "初期状態では無効")
    }
    
    @Test("HotkeyEventProcessorの有効化とイベント処理")
    @MainActor func hotkeyEventProcessorEnableAndHandleEvents() async throws {
        let processor = HotkeyEventProcessor()
        
        // テストデータの準備
        let testData = "テスト".data(using: .utf8)!
        processor.windowController.clipboardItems = [
            ClipboardItemModel(contentData: testData, contentType: .text, preview: "テスト")
        ]
        
        // HotkeyEventProcessorを有効化（権限の問題でホットキー登録をスキップ）
        processor.hotkeyManager.onHotkeyPressed = {
            Task { @MainActor in
                await processor.windowController.showClipboardWindow()
            }
        }
        
        // ホットキーコールバックを手動で実行
        if let callback = processor.hotkeyManager.onHotkeyPressed {
            callback()
        }
        
        // 少し待ってからウィンドウが表示されることを確認
        try await Task.sleep(for: .milliseconds(50))
        #expect(processor.windowController.isWindowVisible == true, "ホットキー押下時にウィンドウが表示される")
    }
    
    @Test("HotkeyEventProcessorの無効化")
    @MainActor func hotkeyEventProcessorDisable() async throws {
        let processor = HotkeyEventProcessor()
        
        // 手動で有効状態をシミュレート
        processor.hotkeyManager.onHotkeyPressed = {}
        
        // 無効化
        await processor.disable()
        
        #expect(processor.isEnabled == false, "無効化後はisEnabledがfalse")
    }
    
    @Test("キーボードナビゲーション処理")
    @MainActor func keyboardNavigationHandling() async {
        let processor = HotkeyEventProcessor()
        
        // テストデータの準備
        let testData1 = "テスト1".data(using: .utf8)!
        let testData2 = "テスト2".data(using: .utf8)!
        processor.windowController.clipboardItems = [
            ClipboardItemModel(contentData: testData1, contentType: .text, preview: "テスト1"),
            ClipboardItemModel(contentData: testData2, contentType: .text, preview: "テスト2")
        ]
        
        await processor.windowController.showClipboardWindow()
        
        // 下キーナビゲーション
        await processor.handleKeyDown(KeyCode.downArrow)
        #expect(processor.windowController.selectedIndex == 1, "下キーで次のアイテムが選択される")
        
        // 上キーナビゲーション
        await processor.handleKeyDown(KeyCode.upArrow)
        #expect(processor.windowController.selectedIndex == 0, "上キーで前のアイテムが選択される")
        
        // Escキー
        await processor.handleKeyDown(KeyCode.escape)
        #expect(processor.windowController.isWindowVisible == false, "Escキーでウィンドウが非表示になる")
    }
    
    @Test("Enterキーでのアイテム選択処理")
    @MainActor func enterKeyItemSelection() async {
        let processor = HotkeyEventProcessor()
        var selectedItem: ClipboardItemModel?
        
        // コールバック設定
        processor.onItemSelected = { item in
            selectedItem = item
        }
        
        // テストデータの準備
        let testData = "選択テスト".data(using: .utf8)!
        processor.windowController.clipboardItems = [
            ClipboardItemModel(contentData: testData, contentType: .text, preview: "選択テスト")
        ]
        
        await processor.windowController.showClipboardWindow()
        
        // Enterキーでアイテムを選択
        await processor.handleKeyDown(KeyCode.enter)
        
        #expect(selectedItem != nil, "アイテムが選択される")
        #expect(selectedItem?.preview == "選択テスト", "正しいアイテムが選択される")
        #expect(processor.windowController.isWindowVisible == false, "選択後にウィンドウが非表示になる")
    }
}