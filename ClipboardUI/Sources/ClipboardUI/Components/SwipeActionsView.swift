import SwiftUI
import SwiftData
import ClipboardCore

/// クリップボードアイテムのスワイプアクション
public struct SwipeActionsView: View {
    let item: ClipboardItemModel
    var showDeleteAction: Bool
    var showFavoriteAction: Bool
    var showCategoryAction: Bool
    var onDelete: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?
    var onCategorySet: ((CategoryModel?) -> Void)?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [CategoryModel]
    @State private var showingCategoryPicker = false
    
    public init(
        item: ClipboardItemModel,
        showDeleteAction: Bool = true,
        showFavoriteAction: Bool = true,
        showCategoryAction: Bool = false,
        onDelete: (() -> Void)? = nil,
        onFavoriteToggle: (() -> Void)? = nil,
        onCategorySet: ((CategoryModel?) -> Void)? = nil
    ) {
        self.item = item
        self.showDeleteAction = showDeleteAction
        self.showFavoriteAction = showFavoriteAction
        self.showCategoryAction = showCategoryAction
        self.onDelete = onDelete
        self.onFavoriteToggle = onFavoriteToggle
        self.onCategorySet = onCategorySet
    }
    
    public var body: some View {
        Group {
            if showCategoryAction {
                Button("カテゴリ", systemImage: "folder") {
                    showingCategoryPicker = true
                }
                .tint(.blue)
            }
            
            if showFavoriteAction {
                Button(
                    item.isFavorite ? "解除" : "お気に入り", 
                    systemImage: item.isFavorite ? "star.fill" : "star"
                ) {
                    toggleFavorite()
                    onFavoriteToggle?()
                }
                .tint(.yellow)
            }
            
            if showDeleteAction {
                Button("削除", systemImage: "trash", role: .destructive) {
                    deleteItem()
                    onDelete?()
                }
                .tint(.red)
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryQuickPickerView(item: item) { selectedCategory in
                setCategoryToItem(selectedCategory)
            }
        }
    }
    
    // MARK: - Actions
    
    private func toggleFavorite() {
        withAnimation(.easeInOut(duration: 0.2)) {
            item.isFavorite.toggle()
            try? modelContext.save()
        }
    }
    
    private func deleteItem() {
        withAnimation(.easeInOut(duration: 0.3)) {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
    
    private func setCategoryToItem(_ category: CategoryModel?) {
        withAnimation(.easeInOut(duration: 0.2)) {
            item.categoryModel = category
            try? modelContext.save()
        }
        onCategorySet?(category)
    }
}

// MARK: - Supporting Views

struct CategoryQuickPickerView: View {
    let item: ClipboardItemModel
    let onCategorySelected: (CategoryModel?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [CategoryModel]
    
    var body: some View {
        NavigationView {
            List {
                Section("クイック選択") {
                    Button(action: {
                        onCategorySelected(nil)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.secondary)
                            Text("カテゴリなし")
                            Spacer()
                            if item.categoryModel == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                if !categories.isEmpty {
                    Section("既存のカテゴリ") {
                        ForEach(categories, id: \.name) { category in
                            Button(action: {
                                onCategorySelected(category)
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: category.systemImage)
                                        .foregroundColor(Color(category.color))
                                    Text(category.name)
                                    Spacer()
                                    if item.categoryModel?.name == category.name {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("カテゴリを選択")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
    }
}