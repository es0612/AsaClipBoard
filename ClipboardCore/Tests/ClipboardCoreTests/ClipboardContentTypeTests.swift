import Testing
import Foundation
@testable import ClipboardCore

@Suite("ClipboardContentType Tests")
struct ClipboardContentTypeTests {
    
    @Test("コンテンツタイプのsystemImage")
    func contentTypeSystemImages() async throws {
        // Given & When & Then
        #expect(ClipboardContentType.text.systemImage == "doc.text")
        #expect(ClipboardContentType.image.systemImage == "photo")
        #expect(ClipboardContentType.url.systemImage == "link")
        #expect(ClipboardContentType.email.systemImage == "envelope")
        #expect(ClipboardContentType.phoneNumber.systemImage == "phone")
        #expect(ClipboardContentType.colorCode.systemImage == "paintpalette")
        #expect(ClipboardContentType.code.systemImage == "chevron.left.forwardslash.chevron.right")
        #expect(ClipboardContentType.richText.systemImage == "textformat")
    }
    
    @Test("コンテンツタイプの列挙")
    func allContentTypes() async throws {
        // Given
        let allTypes = ClipboardContentType.allCases
        
        // Then
        #expect(allTypes.count == 8)
        #expect(allTypes.contains(.text))
        #expect(allTypes.contains(.image))
        #expect(allTypes.contains(.url))
        #expect(allTypes.contains(.email))
        #expect(allTypes.contains(.phoneNumber))
        #expect(allTypes.contains(.colorCode))
        #expect(allTypes.contains(.code))
        #expect(allTypes.contains(.richText))
    }
    
    @Test("コンテンツタイプのrawValue")
    func contentTypeRawValues() async throws {
        // Given & When & Then
        #expect(ClipboardContentType.text.rawValue == "text")
        #expect(ClipboardContentType.image.rawValue == "image")
        #expect(ClipboardContentType.url.rawValue == "url")
        #expect(ClipboardContentType.email.rawValue == "email")
        #expect(ClipboardContentType.phoneNumber.rawValue == "phoneNumber")
        #expect(ClipboardContentType.colorCode.rawValue == "colorCode")
        #expect(ClipboardContentType.code.rawValue == "code")
        #expect(ClipboardContentType.richText.rawValue == "richText")
    }
}