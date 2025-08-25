import SwiftUI
import ClipboardCore
#if canImport(AppKit)
import AppKit
#endif

/// クリップボードアイテムのスマートアクションを表示するSwiftUIビュー
public struct SmartActionsView: View {
    public let item: ClipboardItemModel
    
    public init(item: ClipboardItemModel) {
        self.item = item
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            // コンテンツタイプに基づいてスマートアクションボタンを表示
            switch item.contentType {
            case .url:
                Button(action: openURL) {
                    Image(systemName: "safari")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
                .help("ブラウザで開く")
                
            case .email:
                Button(action: composeEmail) {
                    Image(systemName: "envelope")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.borderless)
                .help("メールを作成")
                
            case .phoneNumber:
                Button(action: makeCall) {
                    Image(systemName: "phone")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                .buttonStyle(.borderless)
                .help("電話をかける")
                
            case .colorCode:
                if let colorPreview = extractColorPreview() {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(colorPreview))
                        .frame(width: 16, height: 16)
                        .help("色: \(item.preview)")
                }
                
            default:
                // その他のタイプは何も表示しない
                EmptyView()
            }
        }
    }
    
    private func openURL() {
        guard let urlString = String(data: item.contentData, encoding: .utf8),
              let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        #if canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    private func composeEmail() {
        guard let emailString = String(data: item.contentData, encoding: .utf8) else { return }
        let mailto = "mailto:\(emailString.trimmingCharacters(in: .whitespacesAndNewlines))"
        guard let url = URL(string: mailto) else { return }
        #if canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    private func makeCall() {
        guard let phoneString = String(data: item.contentData, encoding: .utf8) else { return }
        let tel = "tel:\(phoneString.trimmingCharacters(in: .whitespacesAndNewlines))"
        guard let url = URL(string: tel) else { return }
        #if canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    private func extractColorPreview() -> NSColor? {
        guard let colorString = String(data: item.contentData, encoding: .utf8) else { return nil }
        let trimmed = colorString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 簡単な16進カラーコード解析
        if trimmed.hasPrefix("#") && trimmed.count == 7 {
            let hex = String(trimmed.dropFirst())
            guard let rgb = Int(hex, radix: 16) else { return nil }
            
            let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
            let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
            let blue = CGFloat(rgb & 0xFF) / 255.0
            
            return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        
        return nil
    }
}