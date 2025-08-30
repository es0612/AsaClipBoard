import Foundation
import AppKit

/// スマートアクション値型（コンテンツ分析用）
public enum SmartAction: Equatable, Sendable {
    case openURL(URL)
    case composeEmail(String)
    case call(String)
    case showColorPreview(NSColor)
    case highlightCode(String, language: String)
    
    public var id: String {
        switch self {
        case .openURL(let url): return "url_\(url.absoluteString)"
        case .composeEmail(let email): return "email_\(email)"
        case .call(let phone): return "phone_\(phone)"
        case .showColorPreview(let color): return "color_\(color.hexString ?? "unknown")"
        case .highlightCode(let code, let language): return "code_\(language)_\(code.hashValue)"
        }
    }
    
    public var title: String {
        switch self {
        case .openURL: return "URLを開く"
        case .composeEmail: return "メールを作成"
        case .call: return "電話をかける"
        case .showColorPreview: return "色を表示"
        case .highlightCode: return "コードをハイライト"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .openURL: return "safari"
        case .composeEmail: return "envelope"
        case .call: return "phone"
        case .showColorPreview: return "paintpalette"
        case .highlightCode: return "chevron.left.forwardslash.chevron.right"
        }
    }
    
    public var actionType: String {
        switch self {
        case .openURL: return "openURL"
        case .composeEmail: return "composeEmail"
        // テスト仕様に合わせた名称（後方互換はtoSmartAction側で対応）
        case .call: return "callPhone"
        case .showColorPreview: return "showColor"
        case .highlightCode: return "copyCode"
        }
    }
    
    /// アクションデータをData形式で取得
    /// - Returns: アクションの詳細データ
    public var actionData: Data {
        switch self {
        case .openURL(let url):
            return url.absoluteString.data(using: .utf8) ?? Data()
            
        case .composeEmail(let email):
            return email.data(using: .utf8) ?? Data()
            
        case .call(let phone):
            return phone.data(using: .utf8) ?? Data()
            
        case .showColorPreview(let color):
            let colorString = color.hexString ?? "#000000"
            return colorString.data(using: .utf8) ?? Data()
            
        case .highlightCode(let code, let language):
            let codeData: [String: String] = [
                "code": code,
                "language": language
            ]
            do {
                return try JSONSerialization.data(withJSONObject: codeData)
            } catch {
                print("Warning: Failed to serialize code data: \(error.localizedDescription)")
                return Data()
            }
        }
    }
}

// NSColorの拡張
extension NSColor {
    var hexString: String? {
        guard let rgbColor = self.usingColorSpace(.deviceRGB) else { return nil }
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    convenience init?(hex: String) {
        var clean = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasPrefix("#") { clean.removeFirst() }

        func component(_ str: String, start: Int, len: Int) -> CGFloat? {
            let startIdx = str.index(str.startIndex, offsetBy: start)
            let endIdx = str.index(startIdx, offsetBy: len)
            let substr = String(str[startIdx..<endIdx])
            guard let value = UInt64(substr, radix: 16) else { return nil }
            let scale: CGFloat = (len == 1) ? 15.0 : 255.0
            let normalized = CGFloat(value) / scale
            return (len == 1) ? (normalized) : (normalized)
        }

        switch clean.count {
        case 3: // RGB (4bit each)
            guard let r = component(clean, start: 0, len: 1),
                  let g = component(clean, start: 1, len: 1),
                  let b = component(clean, start: 2, len: 1) else { return nil }
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        case 4: // RGBA (4bit each)
            guard let r = component(clean, start: 0, len: 1),
                  let g = component(clean, start: 1, len: 1),
                  let b = component(clean, start: 2, len: 1),
                  let a = component(clean, start: 3, len: 1) else { return nil }
            self.init(red: r, green: g, blue: b, alpha: a)
        case 6: // RRGGBB
            guard let r = component(clean, start: 0, len: 2),
                  let g = component(clean, start: 2, len: 2),
                  let b = component(clean, start: 4, len: 2) else { return nil }
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        case 8: // RRGGBBAA
            guard let r = component(clean, start: 0, len: 2),
                  let g = component(clean, start: 2, len: 2),
                  let b = component(clean, start: 4, len: 2),
                  let a = component(clean, start: 6, len: 2) else { return nil }
            self.init(red: r, green: g, blue: b, alpha: a)
        default:
            return nil
        }
    }
}

/// レガシーサポート用のSmartAction構造体
public struct SmartActionStruct: Equatable, Sendable {
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
    public func toSmartAction() -> SmartAction? {
        let dataString = String(data: actionData, encoding: .utf8) ?? ""
        
        switch actionType {
        case "openURL":
            guard let url = URL(string: dataString) else { return nil }
            return .openURL(url)
        case "composeEmail":
            return .composeEmail(dataString)
        case "call", "callPhone":
            return .call(dataString)
        case "showColorPreview", "showColor":
            guard let color = NSColor(hex: dataString) else { return nil }
            return .showColorPreview(color)
        case "highlightCode", "copyCode", "formatCode":
            guard let data = actionData.isEmpty ? nil : actionData,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                  let code = json["code"],
                  let language = json["language"] else { return nil }
            return .highlightCode(code, language: language)
        default:
            return nil
        }
    }
}
