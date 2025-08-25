import SwiftUI
import SwiftData
import ClipboardCore
#if canImport(AppKit)
import AppKit
#endif

/// クリップボードアイテムの右クリックコンテキストメニュー
public struct ClipboardItemContextMenu: View {
    let item: ClipboardItemModel
    var onCopy: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?
    var onCategorySet: ((CategoryModel?) -> Void)?
    var onDelete: (() -> Void)?
    
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [CategoryModel]
    @State private var showingCategoryPicker = false
    
    public init(
        item: ClipboardItemModel,
        onCopy: (() -> Void)? = nil,
        onFavoriteToggle: (() -> Void)? = nil,
        onCategorySet: ((CategoryModel?) -> Void)? = nil,
        onDelete: (() -> Void)? = nil
    ) {
        self.item = item
        self.onCopy = onCopy
        self.onFavoriteToggle = onFavoriteToggle
        self.onCategorySet = onCategorySet
        self.onDelete = onDelete
    }
    
    public var body: some View {
        Group {
            // コピーアクション
            Button("クリップボードにコピー", systemImage: "doc.on.doc") {
                copyToClipboard()
                onCopy?()
            }
            
            // お気に入りアクション
            Button(
                item.isFavorite ? "お気に入りから削除" : "お気に入りに追加", 
                systemImage: item.isFavorite ? "star.fill" : "star"
            ) {
                toggleFavorite()
                onFavoriteToggle?()
            }
            
            Divider()
            
            // カテゴリ設定メニュー
            Menu("カテゴリを設定", systemImage: "folder") {
                Button("カテゴリなし", systemImage: "minus.circle") {
                    setCategoryToItem(nil)
                }
                
                if !categories.isEmpty {
                    Divider()
                    
                    ForEach(categories, id: \.name) { category in
                        Button(category.name, systemImage: category.systemImage) {
                            setCategoryToItem(category)
                        }
                    }
                }
                
                Divider()
                
                Button("新しいカテゴリ...", systemImage: "plus.circle") {
                    showingCategoryPicker = true
                }
            }
            
            Divider()
            
            // 削除アクション
            Button("削除", systemImage: "trash", role: .destructive) {
                deleteItem()
                onDelete?()
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(item: item) { selectedCategory in
                setCategoryToItem(selectedCategory)
            }
        }
    }
    
    // MARK: - Actions
    
    private func copyToClipboard() {
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
    
    private func toggleFavorite() {
        withAnimation {
            item.isFavorite.toggle()
            try? modelContext.save()
        }
    }
    
    private func setCategoryToItem(_ category: CategoryModel?) {
        withAnimation {
            item.categoryModel = category
            try? modelContext.save()
        }
        onCategorySet?(category)
    }
    
    private func deleteItem() {
        withAnimation {
            modelContext.delete(item)
            try? modelContext.save()
        }
    }
}

// MARK: - Supporting Views

struct CategoryPickerView: View {
    let item: ClipboardItemModel
    let onCategorySelected: (CategoryModel?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var newCategoryName = ""
    @State private var selectedColor = "blue"
    @State private var selectedIcon = "folder"
    
    private let availableColors = ["blue", "red", "green", "yellow", "purple", "orange", "pink"]
    private let availableIcons = ["folder", "bookmark", "star", "heart", "flag", "tag", "paperplane"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("新しいカテゴリを作成")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("カテゴリ名")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    TextField("カテゴリ名を入力", text: $newCategoryName)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("色")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        ForEach(availableColors, id: \.self) { color in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(color))
                                .frame(height: 40)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("アイコン")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        ForEach(availableIcons, id: \.self) { icon in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.controlBackgroundColor))
                                .frame(height: 40)
                                .overlay(
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundColor(selectedIcon == icon ? .accentColor : .secondary)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedIcon == icon ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedIcon = icon
                                }
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("作成") {
                        createCategory()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newCategoryName.isEmpty)
                }
            }
            .padding()
            .frame(width: 300, height: 500)
        }
    }
    
    private func createCategory() {
        let newCategory = CategoryModel(
            name: newCategoryName,
            color: selectedColor,
            systemImage: selectedIcon
        )
        
        modelContext.insert(newCategory)
        try? modelContext.save()
        
        onCategorySelected(newCategory)
        dismiss()
    }
}