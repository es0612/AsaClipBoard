import Testing
import SwiftUI
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("ContentTypeIcon Tests")
struct ContentTypeIconTests {
    
    @Test("各コンテンツタイプに対するアイコン表示")
    func contentTypeIconDisplay() async throws {
        // Given
        let textIcon = await ContentTypeIcon(type: .text)
        let imageIcon = await ContentTypeIcon(type: .image)
        let urlIcon = await ContentTypeIcon(type: .url)
        
        // When & Then
        #expect(await textIcon.type == .text)
        #expect(await imageIcon.type == .image)
        #expect(await urlIcon.type == .url)
    }
    
    @Test("アイコンサイズの設定")
    func iconSizeConfiguration() async throws {
        // Given
        let icon = await ContentTypeIcon(type: .text, size: 24)
        
        // When & Then
        #expect(await icon.size == 24)
    }
}