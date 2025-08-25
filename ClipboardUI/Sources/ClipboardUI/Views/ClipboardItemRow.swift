import SwiftUI
import ClipboardCore

/// クリップボードアイテムの行表示を行うSwiftUIビュー
public struct ClipboardItemRow: View {
    public let item: ClipboardItemModel
    
    public init(item: ClipboardItemModel) {
        self.item = item
    }
    
    public var body: some View {
        HStack {
            ContentTypeIcon(type: item.contentType)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .lineLimit(2)
                    .font(.body)
                
                HStack {
                    Text(item.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            SmartActionsView(item: item)
        }
        .padding(.vertical, 4)
    }
}