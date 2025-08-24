import Foundation

/// クリップボードアイテムのコンテンツタイプ
public enum ClipboardContentType: String, CaseIterable, Codable, Sendable {
    case text
    case image
    case url
    case email
    case phoneNumber
    case colorCode
    case code
    case richText
    
    /// コンテンツタイプに対応するSF Symbolsアイコン名
    public var systemImage: String {
        switch self {
        case .text: return "doc.text"
        case .image: return "photo"
        case .url: return "link"
        case .email: return "envelope"
        case .phoneNumber: return "phone"
        case .colorCode: return "paintpalette"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .richText: return "textformat"
        }
    }
    
    /// テキストコンテンツからコンテンツタイプを自動検出
    public static func detectContentType(for text: String) -> ClipboardContentType {
        let lowercaseText = text.lowercased()
        
        // URL検出
        if text.contains("http://") || text.contains("https://") || text.contains("www.") {
            return .url
        }
        
        // メール検出
        if text.contains("@") && text.contains(".") {
            let emailRegex = try? NSRegularExpression(pattern: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}"#)
            if let regex = emailRegex, regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count)) != nil {
                return .email
            }
        }
        
        // 電話番号検出 - よりしっかりとした電話番号パターンのみ
        let phoneRegex = try? NSRegularExpression(pattern: #"(\+\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3,4}[-.\s]?\d{4}"#)
        if let regex = phoneRegex, regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count)) != nil {
            // スペースのみの数字は除外
            if !text.trimmingCharacters(in: .whitespacesAndNewlines).allSatisfy({ $0.isNumber || $0.isWhitespace }) {
                return .phoneNumber
            }
        }
        
        // カラーコード検出
        if text.contains("#") {
            let hexColorRegex = try? NSRegularExpression(pattern: #"#[0-9a-fA-F]{3,8}"#)
            if let regex = hexColorRegex, regex.firstMatch(in: text, range: NSRange(location: 0, length: text.count)) != nil {
                return .colorCode
            }
        }
        
        // コード検出
        let codeIndicators = ["{", "}", "function", "class", "import", "def", "var", "let", "const", "func"]
        let indicatorCount = codeIndicators.reduce(0) { count, indicator in
            count + (lowercaseText.contains(indicator) ? 1 : 0)
        }
        if indicatorCount >= 2 {
            return .code
        }
        
        return .text
    }
}