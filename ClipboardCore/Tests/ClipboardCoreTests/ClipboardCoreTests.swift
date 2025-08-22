import Testing
@testable import ClipboardCore

@Suite("ClipboardCore Tests")
struct ClipboardCoreTests {
    
    @Test("パッケージ初期化")
    func packageInitialization() async throws {
        // Given & When
        ClipboardCore.initialize()
        
        // Then
        #expect(ClipboardCore.version == "1.0.0")
    }
}