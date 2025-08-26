import Testing
import SwiftUI
@testable import ClipboardUI
import ClipboardCore

@Suite("MenuBarExtraManager Tests")
struct MenuBarExtraManagerTests {
    
    @Test("MenuBarExtraManagerの初期化")
    @MainActor func menuBarExtraManagerInitialization() {
        let manager = MenuBarExtraManager()
        
        #expect(manager.quickPreviewItems.isEmpty == true, "初期状態ではクイックプレビューアイテムが空")
        #expect(manager.isMenuBarVisible == true, "初期状態ではメニューバーアイコンが表示")
        #expect(manager.statusMessage == "準備完了", "初期状態のステータスメッセージ")
    }
    
    @Test("クイックプレビューアイテムの更新")
    @MainActor func quickPreviewItemsUpdate() {
        let manager = MenuBarExtraManager()
        
        // テストデータの準備
        let testData1 = "テスト1".data(using: .utf8)!
        let testData2 = "テスト2".data(using: .utf8)!
        
        let items = [
            ClipboardItemModel(contentData: testData1, contentType: .text, preview: "テスト1"),
            ClipboardItemModel(contentData: testData2, contentType: .text, preview: "テスト2")
        ]
        
        manager.updateQuickPreviewItems(items)
        
        #expect(manager.quickPreviewItems.count == 2, "クイックプレビューアイテムが更新される")
        #expect(manager.quickPreviewItems.first?.preview == "テスト1", "最初のアイテムが正しく設定される")
        #expect(manager.statusMessage.contains("2"), "ステータスメッセージにアイテム数が表示される")
    }
    
    @Test("メニューバーアイコンの表示制御")
    @MainActor func menuBarIconVisibilityControl() {
        let manager = MenuBarExtraManager()
        
        // 非表示にする
        manager.setMenuBarVisibility(false)
        #expect(manager.isMenuBarVisible == false, "メニューバーアイコンが非表示になる")
        
        // 表示にする
        manager.setMenuBarVisibility(true)
        #expect(manager.isMenuBarVisible == true, "メニューバーアイコンが表示される")
    }
    
    @Test("クイックプレビューの制限")
    @MainActor func quickPreviewItemLimit() {
        let manager = MenuBarExtraManager()
        
        // 6個のアイテムを作成（制限は5個）
        let items = (1...6).map { index in
            let testData = "テスト\(index)".data(using: .utf8)!
            return ClipboardItemModel(contentData: testData, contentType: .text, preview: "テスト\(index)")
        }
        
        manager.updateQuickPreviewItems(items)
        
        #expect(manager.quickPreviewItems.count == 5, "クイックプレビューは最大5個に制限される")
        #expect(manager.quickPreviewItems.first?.preview == "テスト1", "最新のアイテムから5個が表示される")
    }
    
    @Test("空のクリップボード履歴の処理")
    @MainActor func emptyClipboardHistoryHandling() {
        let manager = MenuBarExtraManager()
        
        manager.updateQuickPreviewItems([])
        
        #expect(manager.quickPreviewItems.isEmpty == true, "空の履歴が正しく処理される")
        #expect(manager.statusMessage == "履歴なし", "適切なステータスメッセージが表示される")
    }
    
    @Test("ウィンドウ表示トリガー")
    @MainActor func windowDisplayTrigger() {
        let manager = MenuBarExtraManager()
        var windowShown = false
        
        // コールバック設定
        manager.onShowWindow = {
            windowShown = true
        }
        
        // ウィンドウ表示をトリガー
        manager.triggerShowWindow()
        
        #expect(windowShown == true, "ウィンドウ表示コールバックが実行される")
    }
}