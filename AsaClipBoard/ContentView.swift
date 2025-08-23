import SwiftUI
import SwiftData
import ClipboardCore
import ClipboardUI

struct ClipboardHistoryView: View {
    @Environment(ClipboardManager.self) private var clipboardManager
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView()
            
            // サンプルのクリップボードアイテムを表示
            ScrollView {
                LazyVStack(spacing: 4) {
                    // プレースホルダーアイテム
                    SampleClipboardItemRow()
                    SampleClipboardItemRow()
                }
                .padding(.horizontal, 8)
            }
            
            Spacer()
            
            FooterView()
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("クリップボード履歴")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct SampleClipboardItemRow: View {
    var body: some View {
        HStack {
            ContentTypeIcon(type: .text)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("サンプルテキスト")
                    .lineLimit(2)
                    .font(.body)
                
                HStack {
                    Text("2分前")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct FooterView: View {
    var body: some View {
        HStack {
            Text("0 項目")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("すべてクリア") {}
                .font(.caption)
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

#Preview {
    ClipboardHistoryView()
        .environment(ClipboardManager())
}