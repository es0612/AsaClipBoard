import SwiftUI
import SwiftData
import ClipboardCore
#if canImport(AppKit)
import AppKit
#endif

/// メインのクリップボード履歴表示ビュー
public struct ClipboardHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ClipboardItemModel.timestamp, order: .reverse) 
    private var allItems: [ClipboardItemModel]
    
    @State private var searchText = ""
    @State private var selectedFilter: ContentFilter = .all
    
    private var filteredItems: [ClipboardItemModel] {
        let filtered = allItems.filter { item in
            // フィルター適用
            if selectedFilter != .all, let filterType = selectedFilter.contentType {
                if item.contentType != filterType {
                    return false
                }
            }
            
            // 検索適用
            if !searchText.isEmpty {
                return item.preview.localizedCaseInsensitiveContains(searchText)
            }
            
            return true
        }
        
        // パフォーマンスのため最大100件に制限
        return Array(filtered.prefix(100))
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            SearchBar(text: $searchText)
            
            // フィルターバー
            FilterBar(selectedFilter: $selectedFilter)
            
            // コンテンツエリア
            if filteredItems.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "クリップボード履歴が空です" : "検索結果が見つかりません",
                    systemImage: "doc.on.clipboard",
                    description: Text(searchText.isEmpty ? "何かをコピーすると、ここに表示されます" : "検索条件を変更してお試しください")
                )
            } else {
                List(filteredItems) { item in
                    ClipboardItemRow(item: item)
                        .onTapGesture {
                            copyToClipboard(item)
                        }
                        .contextMenu {
                            ClipboardItemContextMenu(item: item)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("削除", systemImage: "trash", role: .destructive) {
                                deleteItem(item)
                            }
                            
                            Button("お気に入り", systemImage: item.isFavorite ? "star.fill" : "star") {
                                toggleFavorite(item)
                            }
                            .tint(.yellow)
                        }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 400, height: 600)
        .searchable(text: $searchText, prompt: "履歴を検索")
    }
    
    // MARK: - Actions
    
    private func copyToClipboard(_ item: ClipboardItemModel) {
        #if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item.contentType {
        case .text, .url, .email, .phoneNumber, .colorCode, .code, .richText:
            if let string = String(data: item.contentData, encoding: .utf8) {
                pasteboard.setString(string, forType: .string)
            }
        case .image:
            if let image = NSImage(data: item.contentData) {
                pasteboard.writeObjects([image])
            }
        }
        #endif
    }
    
    private func deleteItem(_ item: ClipboardItemModel) {
        withAnimation {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
    
    private func toggleFavorite(_ item: ClipboardItemModel) {
        withAnimation {
            item.isFavorite.toggle()
            try? modelContext.save()
        }
    }
}

// MARK: - Supporting Views

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("履歴を検索", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button("クリア") {
                    text = ""
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(6)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

struct FilterBar: View {
    @Binding var selectedFilter: ContentFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ContentFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: filter.systemImage)
                                .font(.caption)
                            Text(filter.rawValue)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(selectedFilter == filter ? Color.accentColor : Color(.controlBackgroundColor))
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .cornerRadius(4)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 4)
    }
}

struct ClipboardItemContextMenu: View {
    let item: ClipboardItemModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button("コピー", systemImage: "doc.on.doc") {
            // Copy functionality handled by main view
        }
        
        Button("お気に入りに追加", systemImage: item.isFavorite ? "star.fill" : "star") {
            item.isFavorite.toggle()
            try? modelContext.save()
        }
        
        Divider()
        
        Button("削除", systemImage: "trash", role: .destructive) {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
}

public enum ContentFilter: String, CaseIterable {
    case all = "すべて"
    case text = "テキスト"
    case image = "画像"
    case url = "URL"
    case code = "コード"
    
    var contentType: ClipboardContentType? {
        switch self {
        case .all: return nil
        case .text: return .text
        case .image: return .image
        case .url: return .url
        case .code: return .code
        }
    }
    
    var systemImage: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .text: return "doc.text"
        case .image: return "photo"
        case .url: return "link"
        case .code: return "chevron.left.forwardslash.chevron.right"
        }
    }
}