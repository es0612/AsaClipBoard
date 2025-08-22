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
}