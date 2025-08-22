import Testing
import SwiftUI
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("ContentTypeIcon Tests")
struct ContentTypeIconTests {
    
    @Test("各コンテンツタイプに対するアイコン表示")
    func contentTypeIconDisplay() async throws {
        // Given
        let textIcon = ContentTypeIcon(type: .text)
        let imageIcon = ContentTypeIcon(type: .image)
        let urlIcon = ContentTypeIcon(type: .url)
        
        // When & Then
        #expect(textIcon.type == .text)
        #expect(imageIcon.type == .image)
        #expect(urlIcon.type == .url)
    }
    
    @Test("アイコンサイズの設定")
    func iconSizeConfiguration() async throws {
        // Given
        let icon = ContentTypeIcon(type: .text, size: 24)
        
        // When & Then
        #expect(icon.size == 24)
    }
}