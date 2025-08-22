import Testing
@testable import ClipboardUI

@Suite("ClipboardUI Tests")
struct ClipboardUITests {
    
    @Test("パッケージ初期化")
    func packageInitialization() async throws {
        // Given & When
        ClipboardUI.initialize()
        
        // Then
        #expect(ClipboardUI.version == "1.0.0")
    }
}