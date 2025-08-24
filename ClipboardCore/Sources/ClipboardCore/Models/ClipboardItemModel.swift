import Foundation
import SwiftData
#if canImport(AppKit)
import AppKit
#endif

/// クリップボードアイテムのSwiftDataモデル
@Model
public class ClipboardItemModel {
    @Attribute(.unique) public var id: UUID
    public var contentData: Data
    public var contentType: ClipboardContentType
    public var timestamp: Date
    public var isFavorite: Bool
    public var category: String?
    public var preview: String
    public var isEncrypted: Bool
    
    /// 関連するスマートアクション
    @Relationship(deleteRule: .cascade) 
    public var smartActions: [SmartActionModel] = []
    
    /// 所属カテゴリ
    @Relationship 
    public var categoryModel: CategoryModel?
    
    public init(
        id: UUID = UUID(),
        contentData: Data,
        contentType: ClipboardContentType,
        timestamp: Date = Date(),
        isFavorite: Bool = false,
        category: String? = nil,
        preview: String = "",
        isEncrypted: Bool = false
    ) {
        self.id = id
        self.contentData = contentData
        self.contentType = contentType
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.category = category
        self.preview = preview
        self.isEncrypted = isEncrypted
    }
    
    /// NSPasteboardからClipboardItemModelを生成する便利イニシャライザ
    #if canImport(AppKit)
    public convenience init(from pasteboard: NSPasteboard) {
        let (data, type, preview) = Self.extractContent(from: pasteboard)
        self.init(contentData: data, contentType: type, preview: preview)
    }
    
    private static func extractContent(from pasteboard: NSPasteboard) -> (Data, ClipboardContentType, String) {
        // NSPasteboardからコンテンツを抽出
        if let string = pasteboard.string(forType: .string) {
            let data = string.data(using: .utf8) ?? Data()
            let type = ClipboardContentType.detectContentType(for: string)
            let preview = String(string.prefix(100))
            return (data, type, preview)
        } else if let imageData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .tiff) {
            let sizeString = ByteCountFormatter().string(fromByteCount: Int64(imageData.count))
            return (imageData, .image, "画像 (\(sizeString))")
        } else if let rtfData = pasteboard.data(forType: .rtf) {
            let preview = "リッチテキスト (\(ByteCountFormatter().string(fromByteCount: Int64(rtfData.count))))"
            return (rtfData, .richText, preview)
        }
        return (Data(), .text, "")
    }
    #endif
}