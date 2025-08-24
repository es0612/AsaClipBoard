import Testing
import Foundation
@testable import ClipboardCore

@Suite("SmartContentRecognizer Tests")
struct SmartContentRecognizerTests {
    
    @Test("URL検出", arguments: [
        "https://www.apple.com",
        "http://example.com", 
        "Visit https://github.com for code",
        "Check out www.swift.org"
    ])
    func urlDetection(text: String) async throws {
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let urlActions = actions.compactMap { action in
            if action.actionType == "openURL" { return action }
            return nil
        }
        #expect(urlActions.count > 0, "URLアクションが検出される")
        
        // URLアクションの詳細チェック
        let urlAction = try #require(urlActions.first)
        #expect(urlAction.title.contains("開く") || urlAction.title.contains("Open"))
        #expect(urlAction.systemImage == "safari" || urlAction.systemImage == "link")
    }
    
    @Test("メールアドレス検出", arguments: [
        "user@example.com",
        "Contact me at test.user@company.co.jp for info",
        "Send to admin@domain.org please"
    ])
    func emailDetection(text: String) async throws {
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let emailActions = actions.compactMap { action in
            if action.actionType == "composeEmail" { return action }
            return nil
        }
        #expect(emailActions.count > 0, "メールアクションが検出される")
        
        // メールアクションの詳細チェック
        let emailAction = try #require(emailActions.first)
        #expect(emailAction.title.contains("メール") || emailAction.title.contains("Email"))
        #expect(emailAction.systemImage == "envelope")
    }
    
    @Test("電話番号検出", arguments: [
        "+1-555-123-4567",
        "(555) 123-4567",
        "090-1234-5678",
        "+81-90-1234-5678"
    ])
    func phoneNumberDetection(text: String) async throws {
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let phoneActions = actions.compactMap { action in
            if action.actionType == "callPhone" || action.actionType == "sendSMS" { return action }
            return nil
        }
        #expect(phoneActions.count > 0, "電話番号アクションが検出される")
        
        // 電話アクションの詳細チェック
        let phoneAction = try #require(phoneActions.first)
        #expect(phoneAction.title.contains("電話") || phoneAction.title.contains("Call") || 
                phoneAction.title.contains("メッセージ") || phoneAction.title.contains("SMS"))
        #expect(phoneAction.systemImage == "phone" || phoneAction.systemImage == "message")
    }
    
    @Test("カラーコード検出", arguments: [
        "#FF5733",
        "#333",
        "Use color #00FF00 for success",
        "Background: #FFFFFF, Text: #000000"
    ])
    func colorCodeDetection(text: String) async throws {
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let colorActions = actions.compactMap { action in
            if action.actionType == "showColor" { return action }
            return nil
        }
        #expect(colorActions.count > 0, "カラーアクションが検出される")
        
        // カラーアクションの詳細チェック
        let colorAction = try #require(colorActions.first)
        #expect(colorAction.title.contains("色") || colorAction.title.contains("Color"))
        #expect(colorAction.systemImage == "paintpalette" || colorAction.systemImage == "eyedropper")
    }
    
    @Test("コード検出", arguments: [
        "func hello() { print(\"world\") }",
        "class MyClass { var name: String }",
        "import Foundation\nlet x = 10",
        "const handleClick = () => { console.log('clicked'); }"
    ])
    func codeDetection(text: String) async throws {
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let codeActions = actions.compactMap { action in
            if action.actionType == "copyCode" || action.actionType == "formatCode" { return action }
            return nil
        }
        #expect(codeActions.count > 0, "コードアクションが検出される")
        
        // コードアクションの詳細チェック
        let codeAction = try #require(codeActions.first)
        #expect(codeAction.title.contains("コード") || codeAction.title.contains("Code"))
        #expect(codeAction.systemImage == "chevron.left.forwardslash.chevron.right" || 
                codeAction.systemImage == "doc.text")
    }
    
    @Test("混合コンテンツ検出")
    func mixedContentDetection() async throws {
        // Given
        let text = """
        Please visit https://www.apple.com and contact us at support@apple.com 
        or call (555) 123-4567. Use color #FF5733 for the header.
        """
        
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        #expect(actions.count >= 4, "複数のアクションタイプが検出される")
        
        // 各タイプのアクションが含まれていることを確認
        let actionTypes = Set(actions.map { $0.actionType })
        #expect(actionTypes.contains("openURL"), "URLアクションが含まれる")
        #expect(actionTypes.contains("composeEmail"), "メールアクションが含まれる") 
        #expect(actionTypes.contains("callPhone") || actionTypes.contains("sendSMS"), "電話アクションが含まれる")
        #expect(actionTypes.contains("showColor"), "カラーアクションが含まれる")
    }
    
    @Test("空文字とテキストのみの処理")
    func emptyAndPlainTextHandling() async throws {
        // Given
        let emptyText = ""
        let plainText = "This is just plain text without any special content."
        
        // When
        let emptyActions = await SmartContentRecognizer.analyzeContent(emptyText)
        let plainActions = await SmartContentRecognizer.analyzeContent(plainText)
        
        // Then
        #expect(emptyActions.isEmpty, "空文字ではアクションが生成されない")
        #expect(plainActions.isEmpty, "プレーンテキストではアクションが生成されない")
    }
    
    @Test("RegexBuilder統合でのコンテンツタイプ検出")
    func regexBuilderContentTypeDetection() async throws {
        // Given
        let testCases: [(String, ClipboardContentType)] = [
            ("https://www.example.com", .url),
            ("user@domain.com", .email),
            ("+1-555-123-4567", .phoneNumber),
            ("#FF5733", .colorCode),
            ("func test() { return true }", .code),
            ("Just plain text", .text)
        ]
        
        // When & Then
        for (text, expectedType) in testCases {
            let detectedType = SmartContentRecognizer.detectContentType(text)
            #expect(detectedType == expectedType, "「\(text)」は\(expectedType)として検出されるべき")
        }
    }
}