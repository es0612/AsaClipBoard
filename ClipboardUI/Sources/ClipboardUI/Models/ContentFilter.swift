import ClipboardCore

/// コンテンツタイプ別フィルタリング用の列挙型
public enum ContentFilter: String, CaseIterable {
    case all = "すべて"
    case text = "テキスト"
    case image = "画像"
    case url = "URL"
    case code = "コード"
    
    /// ContentFilter を ClipboardContentType に変換
    public var contentType: ClipboardContentType? {
        switch self {
        case .all: return nil
        case .text: return .text
        case .image: return .image
        case .url: return .url
        case .code: return .code
        }
    }
    
    /// フィルターのシステムアイコン名
    public var systemImage: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .text: return "doc.text"
        case .image: return "photo"
        case .url: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        }
    }
}