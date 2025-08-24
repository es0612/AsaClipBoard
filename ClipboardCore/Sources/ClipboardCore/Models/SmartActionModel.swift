import Foundation
import SwiftData

/// スマートアクションのSwiftDataモデル
@Model
public class SmartActionModel {
    @Attribute(.unique) public var id: String
    public var actionType: String
    public var title: String
    public var systemImage: String
    public var actionData: Data
    
    /// 親のクリップボードアイテム（逆参照）
    @Relationship(inverse: \ClipboardItemModel.smartActions) 
    public var clipboardItem: ClipboardItemModel?
    
    public init(
        id: String,
        actionType: String,
        title: String,
        systemImage: String,
        actionData: Data
    ) {
        self.id = id
        self.actionType = actionType
        self.title = title
        self.systemImage = systemImage
        self.actionData = actionData
    }
}