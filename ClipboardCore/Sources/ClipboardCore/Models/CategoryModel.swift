import Foundation
import SwiftData

/// カテゴリのSwiftDataモデル
@Model
public class CategoryModel {
    @Attribute(.unique) public var name: String
    public var color: String
    public var systemImage: String
    public var createdAt: Date
    
    /// このカテゴリに属するクリップボードアイテム
    @Relationship(deleteRule: .nullify, inverse: \ClipboardItemModel.categoryModel) 
    public var clipboardItems: [ClipboardItemModel] = []
    
    public init(
        name: String,
        color: String = "blue",
        systemImage: String = "folder",
        createdAt: Date = Date()
    ) {
        self.name = name
        self.color = color
        self.systemImage = systemImage
        self.createdAt = createdAt
    }
}