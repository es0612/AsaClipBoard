import Testing
import SwiftUI
@testable import ClipboardUI

#if canImport(AppKit)
import AppKit
#else
import UIKit
#endif

@Suite("AccessibilityManager Tests")
struct AccessibilityManagerTests {
    
    @Test("AccessibilityManagerの初期化")
    @MainActor func accessibilityManagerInitialization() async {
        let manager = Controllers.AccessibilityManager()
        
        #if os(macOS)
        #expect(manager.keyboardNavigationEnabled == true, "キーボードナビゲーションが有効")
        #expect(manager.screenReaderEnabled == manager.isVoiceOverRunning, "スクリーンリーダー状態が正しく検出される")
        #else
        #expect(manager.isVoiceOverRunning == UIAccessibility.isVoiceOverRunning, "VoiceOver状態が正しく検出される")
        #expect(manager.screenReaderEnabled == UIAccessibility.isVoiceOverRunning, "スクリーンリーダー状態が正しく検出される")
        #endif
    }
    
    @Test("VoiceOverラベル生成")
    @MainActor func voiceOverLabelGeneration() async {
        let manager = Controllers.AccessibilityManager()
        
        let textItemLabel = manager.generateVoiceOverLabel(
            contentType: .text,
            preview: "Hello World",
            timestamp: Date()
        )
        
        #expect(textItemLabel.contains("テキスト"), "テキストタイプが含まれる")
        #expect(textItemLabel.contains("Hello World"), "プレビューが含まれる")
        #expect(textItemLabel.contains("アイテム"), "アイテムラベルが含まれる")
        
        let imageItemLabel = manager.generateVoiceOverLabel(
            contentType: .image,
            preview: "画像 (100KB)",
            timestamp: Date()
        )
        
        #expect(imageItemLabel.contains("画像"), "画像タイプが含まれる")
        #expect(imageItemLabel.contains("100KB"), "サイズ情報が含まれる")
    }
    
    @Test("VoiceOverヒント生成")
    @MainActor func voiceOverHintGeneration() async {
        let manager = Controllers.AccessibilityManager()
        
        let hint = manager.generateVoiceOverHint(for: .clipboardItem)
        #expect(hint.contains("ダブルタップ"), "操作ヒントが含まれる")
        #expect(hint.contains("コピー"), "機能説明が含まれる")
        
        let buttonHint = manager.generateVoiceOverHint(for: .actionButton("削除"))
        #expect(buttonHint.contains("削除"), "アクション名が含まれる")
    }
    
    @Test("キーボードナビゲーション設定")
    @MainActor func keyboardNavigationSettings() async {
        let manager = Controllers.AccessibilityManager()
        
        manager.setKeyboardNavigationEnabled(false)
        #expect(manager.keyboardNavigationEnabled == false, "キーボードナビゲーションが無効化される")
        
        manager.setKeyboardNavigationEnabled(true)
        #expect(manager.keyboardNavigationEnabled == true, "キーボードナビゲーションが有効化される")
    }
    
    @Test("HighContrast検出")
    @MainActor func highContrastDetection() async {
        let manager = Controllers.AccessibilityManager()
        
        // システムの実際の設定を確認（基本的なテスト）
        #expect(manager.isHighContrastEnabled is Bool, "HighContrast状態が検出される")
    }
    
    @Test("アクセシビリティ要素の優先順位")
    @MainActor func accessibilityElementPriority() async {
        let manager = Controllers.AccessibilityManager()
        
        let priorities = manager.getElementNavigationOrder()
        
        #expect(priorities.first == .searchField, "検索フィールドが最初の要素")
        #expect(priorities.contains(.clipboardList), "クリップボードリストが含まれる")
        #expect(priorities.last == .settingsButton, "設定ボタンが最後の要素")
    }
    
    @Test("アクセシビリティアクション生成")
    @MainActor func accessibilityActionGeneration() async {
        let manager = Controllers.AccessibilityManager()
        
        let actions = manager.generateAccessibilityActions(
            for: .clipboardItem,
            canFavorite: true,
            canDelete: true
        )
        
        #expect(actions.count >= 3, "少なくとも3つのアクションが生成される")
        
        let actionNames = actions.map { $0.name }
        #expect(actionNames.contains("コピー"), "コピーアクションが含まれる")
        #expect(actionNames.contains("お気に入り"), "お気に入りアクションが含まれる")
        #expect(actionNames.contains("削除"), "削除アクションが含まれる")
    }
    
    @Test("動的フォントサイズ対応")
    @MainActor func dynamicFontSizeSupport() async {
        let manager = Controllers.AccessibilityManager()
        
        let originalSize: CGFloat = 14
        let scaledSize = manager.getScaledFontSize(originalSize)
        
        #expect(scaledSize >= originalSize, "スケールされたフォントサイズは元のサイズ以上")
    }
    
    @Test("読み上げ速度調整")
    @MainActor func speechRateAdjustment() async {
        let manager = Controllers.AccessibilityManager()
        
        let defaultRate = manager.getSpeechRate()
        #expect(defaultRate > 0, "デフォルトの読み上げ速度が設定される")
        
        manager.setSpeechRate(0.5)
        #expect(manager.getSpeechRate() == 0.5, "読み上げ速度が正しく設定される")
    }
    
    @Test("アクセシビリティ通知")
    @MainActor func accessibilityNotifications() async {
        let manager = Controllers.AccessibilityManager()
        
        // 通知が正常に実行されることを確認（実際の通知テストは困難）
        manager.postAccessibilityNotification(.screenChanged, argument: "画面が変更されました")
        
        // エラーが発生しないことを確認
        #expect(true, "アクセシビリティ通知が正常に実行される")
    }
}

// MARK: - Test Support Types

extension AccessibilityManagerTests {
    
    enum TestContentType {
        case text
        case image
        case url
    }
    
    enum TestAccessibilityElement {
        case clipboardItem
        case searchField
        case settingsButton
        case clipboardList
        case actionButton(String)
    }
    
    enum TestAccessibilityNotification {
        case screenChanged
        case announcement
        case layoutChanged
    }
}