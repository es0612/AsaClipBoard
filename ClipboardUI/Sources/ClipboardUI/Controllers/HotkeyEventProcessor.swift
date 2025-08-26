import SwiftUI
import Observation
import ClipboardCore
import Carbon

@MainActor
@Observable
public class HotkeyEventProcessor: @unchecked Sendable {
    public let hotkeyManager: HotkeyManager
    public let windowController: ClipboardWindowController
    public var isEnabled: Bool = false
    
    // コールバック
    public var onItemSelected: ((ClipboardItemModel) -> Void)?
    
    // キーイベント監視
    private nonisolated(unsafe) var eventMonitor: Any?
    
    public init() {
        self.hotkeyManager = HotkeyManager()
        self.windowController = ClipboardWindowController()
        
        setupWindowControllerCallback()
    }
    
    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        Task { [weak hotkeyManager = self.hotkeyManager] in
            hotkeyManager?.unregisterHotkey()
        }
    }
    
    // HotkeyEventProcessorを有効化
    public func enable() async throws {
        guard !isEnabled else { return }
        
        // ホットキーコールバックを設定
        hotkeyManager.onHotkeyPressed = { [weak self] in
            Task { @MainActor in
                await self?.handleHotkeyPressed()
            }
        }
        
        // ホットキーを登録
        try await hotkeyManager.registerHotkey(keyCode: 9, modifiers: UInt32(cmdKey)) // Cmd+V
        
        // キーボードイベント監視を開始
        startKeyEventMonitoring()
        
        isEnabled = true
    }
    
    // HotkeyEventProcessorを無効化
    public func disable() async {
        guard isEnabled else { return }
        
        // ホットキーを登録解除
        hotkeyManager.unregisterHotkey()
        
        // キーボードイベント監視を停止
        stopKeyEventMonitoring()
        
        // ウィンドウを非表示
        await windowController.hideClipboardWindow()
        
        isEnabled = false
    }
    
    // ホットキー押下時の処理
    private func handleHotkeyPressed() async {
        await windowController.showClipboardWindow()
    }
    
    // WindowControllerのコールバック設定
    private func setupWindowControllerCallback() {
        windowController.onItemSelected = { [weak self] item in
            self?.onItemSelected?(item)
        }
    }
    
    // キーイベント監視開始
    private func startKeyEventMonitoring() {
        stopKeyEventMonitoring() // 既存のモニターを停止
        
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            Task { @MainActor in
                await self?.handleKeyEvent(event)
            }
            return event
        }
    }
    
    // キーイベント監視停止
    private func stopKeyEventMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    // キーイベント処理
    private func handleKeyEvent(_ event: NSEvent) async {
        // ウィンドウが表示されている時のみ処理
        guard windowController.isWindowVisible else { return }
        
        switch event.keyCode {
        case 125: // Down Arrow
            await handleKeyDown(.downArrow)
            
        case 126: // Up Arrow
            await handleKeyDown(.upArrow)
            
        case 36: // Enter
            await handleKeyDown(.enter)
            
        case 53: // Escape
            await handleKeyDown(.escape)
            
        default:
            break
        }
    }
    
    // キー押下処理
    public func handleKeyDown(_ keyCode: KeyCode) async {
        switch keyCode {
        case .downArrow:
            await windowController.selectNext()
            
        case .upArrow:
            await windowController.selectPrevious()
            
        case .enter:
            await windowController.selectCurrentItem()
            
        case .escape:
            await windowController.hideClipboardWindow()
        }
    }
}

// キーコード列挙型
public enum KeyCode {
    case upArrow
    case downArrow
    case enter
    case escape
}