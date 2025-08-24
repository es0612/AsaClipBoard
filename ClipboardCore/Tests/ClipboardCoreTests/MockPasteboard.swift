import Foundation
#if canImport(AppKit)
import AppKit
#endif

/// テスト用のモックPasteboard
#if canImport(AppKit)
class MockPasteboard {
    private var mockChangeCount: Int = 0
    private var mockContents: [NSPasteboard.PasteboardType: Any] = [:]
    
    var changeCount: Int {
        return mockChangeCount
    }
    
    func string(forType dataType: NSPasteboard.PasteboardType) -> String? {
        return mockContents[dataType] as? String
    }
    
    func data(forType dataType: NSPasteboard.PasteboardType) -> Data? {
        if let string = mockContents[dataType] as? String {
            return string.data(using: .utf8)
        }
        return mockContents[dataType] as? Data
    }
    
    func setString(_ string: String, forType dataType: NSPasteboard.PasteboardType) {
        mockContents[dataType] = string
        mockChangeCount += 1
    }
    
    func setData(_ data: Data, forType dataType: NSPasteboard.PasteboardType) {
        mockContents[dataType] = data
        mockChangeCount += 1
    }
    
    func clearContents() {
        mockContents.removeAll()
        mockChangeCount += 1
    }
    
    // テスト用のヘルパーメソッド
    func simulateClipboardChange() {
        mockChangeCount += 1
    }
}
#else
// macOS以外のプラットフォーム用のダミー実装
class MockPasteboard {
    private var mockChangeCount: Int = 0
    private var mockString: String = ""
    
    var changeCount: Int {
        return mockChangeCount
    }
    
    func setString(_ string: String, forType dataType: String) {
        mockString = string
        mockChangeCount += 1
    }
    
    func string(forType dataType: String) -> String? {
        return mockString
    }
    
    func data(forType dataType: String) -> Data? {
        return mockString.data(using: .utf8)
    }
}
#endif