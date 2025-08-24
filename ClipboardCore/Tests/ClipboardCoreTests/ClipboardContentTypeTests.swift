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
    
    @Test("URL自動検出", arguments: [
        "https://www.apple.com",
        "http://example.com",
        "Visit www.github.com for more info"
    ])
    func urlAutoDetection(text: String) {
        let detectedType = ClipboardContentType.detectContentType(for: text)
        #expect(detectedType == .url)
    }
    
    @Test("メールアドレス自動検出", arguments: [
        "user@example.com",
        "Contact me at test.user@company.co.jp",
        "Send email to admin@domain.org"
    ])
    func emailAutoDetection(text: String) {
        let detectedType = ClipboardContentType.detectContentType(for: text)
        #expect(detectedType == .email)
    }
    
    @Test("カラーコード自動検出", arguments: [
        "#FF5733",
        "The color #00FF00 is green",
        "Use #333 for dark gray"
    ])
    func colorCodeAutoDetection(text: String) {
        let detectedType = ClipboardContentType.detectContentType(for: text)
        #expect(detectedType == .colorCode)
    }
    
    @Test("コード自動検出", arguments: [
        "func hello() { print(\"world\") }",
        "class MyClass { var name: String }",
        "import Foundation\nlet x = 10"
    ])
    func codeAutoDetection(text: String) {
        let detectedType = ClipboardContentType.detectContentType(for: text)
        #expect(detectedType == .code)
    }
    
    @Test("通常テキスト検出")
    func plainTextDetection() {
        let plainTexts = [
            "This is just plain text",
            "今日は良い天気ですね。",
            "123 456 789"
        ]
        
        for text in plainTexts {
            let detectedType = ClipboardContentType.detectContentType(for: text)
            #expect(detectedType == .text, "'\(text)' should be detected as plain text")
        }
    }
}