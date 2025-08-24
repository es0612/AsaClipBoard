import Foundation
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
            // HTTP/HTTPS URL検出
            let httpRegex = try NSRegularExpression(pattern: #"https?://\S+"#)
            let httpMatches = httpRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
            
            for match in httpMatches {
                if let range = Range(match.range, in: text) {
                    let url = String(text[range])
                    actions.append(SmartAction(
                        actionType: "openURL",
                        title: "URLを開く",
                        systemImage: "safari",
                        data: url
                    ))
                }
            }
            
            // WWW URL検出
            let wwwRegex = try NSRegularExpression(pattern: #"www\.\S+"#)
            let wwwMatches = wwwRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
            
            for match in wwwMatches {
                if let range = Range(match.range, in: text) {
                    let url = String(text[range])
                    actions.append(SmartAction(
                        actionType: "openURL",
                        title: "URLを開く",
                        systemImage: "safari",
                        data: url
                    ))
                }
            }
        } catch {
            // Regex作成に失敗した場合はログに記録
            print("URL regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectEmails(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let emailRegex = try NSRegularExpression(pattern: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#)
            let matches = emailRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let email = String(text[range])
                    actions.append(SmartAction(
                        actionType: "composeEmail",
                        title: "メールを作成",
                        systemImage: "envelope",
                        data: email
                    ))
                }
            }
        } catch {
            print("Email regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectPhoneNumbers(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let phoneRegex = try NSRegularExpression(pattern: #"(\+\d{1,3}[-.\s]?)?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{4}"#)
            let matches = phoneRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let phoneNumber = String(text[range])
                    // 電話をかけるアクションを追加
                    actions.append(SmartAction(
                        actionType: "callPhone",
                        title: "電話をかける",
                        systemImage: "phone",
                        data: phoneNumber
                    ))
                    // SMSを送るアクションを追加
                    actions.append(SmartAction(
                        actionType: "sendSMS",
                        title: "メッセージを送る",
                        systemImage: "message",
                        data: phoneNumber
                    ))
                }
            }
        } catch {
            print("Phone regex failed: \(error)")
        }
        
        return actions
    }
    
    private static func detectColorCodes(in text: String) async -> [SmartAction] {
        var actions: [SmartAction] = []
        
        do {
            let hexColorRegex = try NSRegularExpression(pattern: #"#[0-9a-fA-F]{3,8}"#)
            let matches = hexColorRegex.matches(in: text, range: NSRange(location: 0, length: text.count))
            
            for match in matches {
                if let range = Range(match.range, in: text) {
                    let colorCode = String(text[range])
                    actions.append(SmartAction(
                        actionType: "showColor",
                        title: "色を表示",
                        systemImage: "paintpalette",
                        data: colorCode
                    ))
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
            actions.append(SmartAction(
                actionType: "copyCode",
                title: "コードをコピー",
                systemImage: "doc.text",
                data: text
            ))
            actions.append(SmartAction(
                actionType: "formatCode",
                title: "コードをフォーマット",
                systemImage: "chevron.left.forwardslash.chevron.right",
                data: text
            ))
        }
        
        return actions
    }
}