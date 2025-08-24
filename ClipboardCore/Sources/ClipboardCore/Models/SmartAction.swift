import Foundation

/// スマートアクション値型（コンテンツ分析用）
public struct SmartAction: Equatable, Sendable {
    public let id: String
    public let actionType: String
    public let title: String
    public let systemImage: String
    public let actionData: Data
    
    public init(
        id: String = UUID().uuidString,
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
    
    /// 文字列データから作成する便利イニシャライザ
    public init(
        id: String = UUID().uuidString,
        actionType: String,
        title: String,
        systemImage: String,
        data: String
    ) {
        self.init(
            id: id,
            actionType: actionType,
            title: title,
            systemImage: systemImage,
            actionData: data.data(using: .utf8) ?? Data()
        )
    }
    
    /// SmartActionModelに変換
    public func toModel() -> SmartActionModel {
        return SmartActionModel(
            id: id,
            actionType: actionType,
            title: title,
            systemImage: systemImage,
            actionData: actionData
        )
    }
}

/// SmartActionModelの拡張
extension SmartActionModel {
    /// SmartActionから変換する便利イニシャライザ
    public convenience init(from smartAction: SmartAction) {
        self.init(
            id: smartAction.id,
            actionType: smartAction.actionType,
            title: smartAction.title,
            systemImage: smartAction.systemImage,
            actionData: smartAction.actionData
        )
    }
    
    /// SmartAction値型に変換
    public func toSmartAction() -> SmartAction {
        return SmartAction(
            id: id,
            actionType: actionType,
            title: title,
            systemImage: systemImage,
            actionData: actionData
        )
    }
}