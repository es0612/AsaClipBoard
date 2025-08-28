import Foundation
import AppKit
import RegexBuilder

/// スマートコンテンツ認識サービス
public struct SmartContentRecognizer {
    
    /// テキストコンテンツを分析してスマートアクションを生成
    public static func analyzeContent(_ text: String) async -> [SmartAction] {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        return await withTaskGroup(of: [SmartAction].self) { group in
            var allActions: [SmartAction] = []
            
            // 並列でコンテンツ分析を実行
            group.addTask { await detectURLs(in: text) }
            group.addTask { await detectEmails(in: text) }
            group.addTask { await detectPhoneNumbers(in: text) }
            group.addTask { await detectColorCodes(in: text) }
            group.addTask { await detectCode(in: text) }
            
            for await actions in group {
                allActions.append(contentsOf: actions)
            }
            
            return allActions
        }
    }
    
    /// RegexBuilderを使用したコンテンツタイプ検出
    public static func detectContentType(_ text: String) -> ClipboardContentType {
        // 既存のNSRegularExpressionベースの実装を暫定使用
        // TODO: RegexBuilderによる実装に後で置き換える
        return ClipboardContentType.detectContentType(for: text)
    }
    
    // MARK: - Private Methods
    
    private static func detectURLs(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let nsText = text as NSString
            
            // HTTP/HTTPS URL検出
            let httpRegex = try NSRegularExpression(pattern: #"https?://\S+"#)
            let httpMatches = httpRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            for match in httpMatches {
                let matchString = nsText.substring(with: match.range)
                if let url = URL(string: matchString) {
                    actions.append(.openURL(url))
                }
            }
            
            // WWW URL検出
            let wwwRegex = try NSRegularExpression(pattern: #"www\.\S+"#)
            let wwwMatches = wwwRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            for match in wwwMatches {
                let matchString = nsText.substring(with: match.range)
                if let url = URL(string: "https://" + matchString) {
                    actions.append(.openURL(url))
                }
            }
        } catch {
            print("URL regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectEmails(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let nsText = text as NSString
            let emailRegex = try NSRegularExpression(pattern: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#)
            let matches = emailRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            for match in matches {
                let email = nsText.substring(with: match.range)
                actions.append(.composeEmail(email))
            }
        } catch {
            print("Email regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectPhoneNumbers(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let nsText = text as NSString
            let phoneRegex = try NSRegularExpression(pattern: #"(\+\d{1,3}[-.\s]?)?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{4}"#)
            let matches = phoneRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            for match in matches {
                let phoneNumber = nsText.substring(with: match.range)
                actions.append(.call(phoneNumber))
            }
        } catch {
            print("Phone regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectColorCodes(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let nsText = text as NSString
            let hexColorRegex = try NSRegularExpression(pattern: #"#[0-9a-fA-F]{3,8}"#)
            let matches = hexColorRegex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            
            for match in matches {
                let colorString = nsText.substring(with: match.range)
                if let color = NSColor(hex: colorString) {
                    actions.append(.showColorPreview(color))
                }
            }
        } catch {
            print("Color regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectCode(in text: String) async -> [SmartAction] {
        let codeIndicators = ["func ", "function ", "class ", "import ", "def ", "var ", "let ", "const ", "{", "}"]
        let indicatorCount = codeIndicators.reduce(0) { count, indicator in
            count + (text.contains(indicator) ? 1 : 0)
        }
        
        var actions: [SmartAction] = []
        
        if indicatorCount >= 2 {
            let language = detectLanguage(from: text)
            actions.append(.highlightCode(text, language: language))
        }
        
        return actions
    }
    
    private static func detectLanguage(from text: String) -> String {
        let languageIndicators = [
            ("swift", ["func ", "var ", "let ", "import ", "class ", "struct "]),
            ("javascript", ["function ", "var ", "let ", "const ", "=> ", "JSON."]),
            ("python", ["def ", "import ", "class ", "print(", "self.", "__init__"]),
            ("java", ["public class", "private ", "public ", "import ", "System.out"]),
            ("typescript", ["interface ", "type ", "const ", "function ", ": string", ": number"])
        ]
        
        var maxMatches = 0
        var detectedLanguage = "unknown"
        
        for (language, indicators) in languageIndicators {
            let matchCount = indicators.reduce(0) { count, indicator in
                count + (text.contains(indicator) ? 1 : 0)
            }
            if matchCount > maxMatches {
                maxMatches = matchCount
                detectedLanguage = language
            }
        }
        
        return maxMatches > 0 ? detectedLanguage : "unknown"
    }
}