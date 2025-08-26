import Foundation
import Carbon
import Observation

@Observable
public class HotkeyManager: @unchecked Sendable {
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4B4D), id: 1) // 'KM' for Kiro Manager
    private let queue = DispatchQueue(label: "com.kiro.hotkey.manager", qos: .userInitiated)
    private var eventHandlerRef: EventHandlerRef?
    
    public var isHotkeyRegistered: Bool = false
    public var onHotkeyPressed: (() -> Void)?
    
    public init() {}
    
    public func registerHotkey(keyCode: UInt32, modifiers: UInt32) async throws {
        // モディファイアの検証
        guard modifiers != 0 else {
            throw HotkeyManagerError.invalidModifiers
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: HotkeyManagerError.registrationFailed)
                    return
                }
                
                // 既存のホットキーがある場合は登録解除
                self.internalUnregisterHotkey()
                
                let status = RegisterEventHotKey(keyCode, modifiers, self.hotKeyID, 
                                               GetApplicationEventTarget(), 0, &self.hotKeyRef)
                
                if status == noErr {
                    self.isHotkeyRegistered = true
                    do {
                        try self.installEventHandler()
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else {
                    continuation.resume(throwing: HotkeyManagerError.registrationFailed)
                }
            }
        }
    }
    
    public func unregisterHotkey() {
        queue.sync {
            internalUnregisterHotkey()
        }
    }
    
    private func internalUnregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
            isHotkeyRegistered = false
        }
        
        if let eventHandlerRef = eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }
    
    private func installEventHandler() throws {
        // Carbon Event Handler の設定
        let eventHandler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            guard let userData = userData else { return noErr }
            let hotkeyManager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
            
            // メインスレッドでコールバックを実行
            DispatchQueue.main.async {
                hotkeyManager.onHotkeyPressed?()
            }
            
            return noErr
        }
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                     eventKind: OSType(kEventHotKeyPressed))
        
        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(), 
            eventHandler, 
            1, 
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(), 
            &eventHandlerRef
        )
        
        if installStatus != noErr {
            throw HotkeyManagerError.eventHandlerInstallationFailed
        }
    }
    
    deinit {
        // 同期的にクリーンアップ
        internalUnregisterHotkey()
    }
}

// エラー型の定義
public enum HotkeyManagerError: Error, LocalizedError {
    case registrationFailed
    case invalidModifiers
    case eventHandlerInstallationFailed
    
    public var errorDescription: String? {
        switch self {
        case .registrationFailed:
            return "ホットキーの登録に失敗しました"
        case .invalidModifiers:
            return "無効なモディファイアキーです"
        case .eventHandlerInstallationFailed:
            return "イベントハンドラーのインストールに失敗しました"
        }
    }
}