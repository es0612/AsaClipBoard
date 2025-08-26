import SwiftUI
import Observation
import ClipboardCore

@MainActor
@Observable
public class ClipboardWindowController: @unchecked Sendable {
    public var isWindowVisible: Bool = false
    public var selectedIndex: Int = 0
    public var clipboardItems: [ClipboardItemModel] = []
    
    // コールバック
    public var onItemSelected: ((ClipboardItemModel) -> Void)?
    
    public init() {}
    
    // ウィンドウ表示
    public func showClipboardWindow() async {
        // アイテムが空の場合は表示しない
        guard !clipboardItems.isEmpty else {
            isWindowVisible = false
            return
        }
        
        isWindowVisible = true
        selectedIndex = 0
    }
    
    // ウィンドウ非表示
    public func hideClipboardWindow() async {
        isWindowVisible = false
    }
    
    // 次のアイテムを選択
    public func selectNext() async {
        guard !clipboardItems.isEmpty else { return }
        
        selectedIndex = (selectedIndex + 1) % clipboardItems.count
    }
    
    // 前のアイテムを選択
    public func selectPrevious() async {
        guard !clipboardItems.isEmpty else { return }
        
        selectedIndex = selectedIndex == 0 ? clipboardItems.count - 1 : selectedIndex - 1
    }
    
    // 現在選択されているアイテムを決定
    public func selectCurrentItem() async {
        guard !clipboardItems.isEmpty,
              selectedIndex < clipboardItems.count else { return }
        
        let selectedItem = clipboardItems[selectedIndex]
        onItemSelected?(selectedItem)
        
        // 選択後はウィンドウを非表示
        await hideClipboardWindow()
    }
}