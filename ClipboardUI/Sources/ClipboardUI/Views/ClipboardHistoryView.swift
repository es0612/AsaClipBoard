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
                            SwipeActionsView(
                                item: item,
                                showDeleteAction: true,
                                showFavoriteAction: true,
                                showCategoryAction: true,
                                onDelete: { deleteItem(item) },
                                onFavoriteToggle: { toggleFavorite(item) },
                                onCategorySet: { _ in }
                            )
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


