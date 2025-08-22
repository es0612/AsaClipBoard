import Foundation
import SwiftData

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
}