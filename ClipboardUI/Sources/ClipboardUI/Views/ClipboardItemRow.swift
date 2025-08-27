import SwiftUI
import ClipboardCore

/// クリップボードアイテムの行表示を行うSwiftUIビュー
public struct ClipboardItemRow: View {
    public let item: ClipboardItemModel
    @State private var accessibilityManager = Controllers.AccessibilityManager()
    
    public init(item: ClipboardItemModel) {
        self.item = item
    }
    
    public var body: some View {
        HStack {
            ContentTypeIcon(type: item.contentType)
                .accessibilityHidden(true) // アイコンは重複するため隠す
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .lineLimit(2)
                    .font(.system(size: accessibilityManager.getScaledFontSize(14)))
                    .accessibilityLabel(generateAccessibilityLabel())
                
                HStack {
                    Text(item.timestamp.formatted(.relative(presentation: .named)))
                        .font(.system(size: accessibilityManager.getScaledFontSize(12)))
                        .foregroundColor(.secondary)
                        .accessibilityHidden(true) // メインラベルに含まれるため隠す
                    
                    Spacer()
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                            .accessibilityLabel("お気に入り")
                            .accessibilityHint("このアイテムはお気に入りに登録されています")
                    }
                }
            }
            
            Spacer()
            
            SmartActionsView(item: item)
                .accessibilityLabel("スマートアクション")
                .accessibilityHint("利用可能なアクションを表示")
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(generateAccessibilityLabel())
        .accessibilityHint(accessibilityManager.generateVoiceOverHint(for: .clipboardItem))
        .accessibilityAddTraits(.isButton)
        .accessibilityActions {
            Button("コピー") {
                // コピーアクション（親ビューで実装される）
            }
            
            if item.isFavorite {
                Button("お気に入りから削除") {
                    // お気に入り削除アクション
                }
            } else {
                Button("お気に入りに追加") {
                    // お気に入り追加アクション
                }
            }
            
            Button("削除") {
                // 削除アクション
            }
        }
    }
    
    private func generateAccessibilityLabel() -> String {
        let contentType = ContentType(from: item.contentType)
        return accessibilityManager.generateVoiceOverLabel(
            contentType: contentType,
            preview: item.preview,
            timestamp: item.timestamp
        )
    }
}

// MARK: - ContentType Extension
extension ContentType {
    init(from clipboardContentType: ClipboardContentType) {
        switch clipboardContentType {
        case .text: self = .text
        case .image: self = .image
        case .url: self = .url
        case .email: self = .email
        case .phoneNumber: self = .phoneNumber
        case .colorCode: self = .colorCode
        case .code: self = .code
        case .richText: self = .richText
        }
    }
}