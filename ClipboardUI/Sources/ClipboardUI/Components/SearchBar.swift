import SwiftUI

/// リアルタイム検索機能を提供するSearchBarコンポーネント
public struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onSearchChanged: ((String) -> Void)?
    var showSearchCount: Bool
    var searchCount: Int
    
    public init(
        text: Binding<String>, 
        placeholder: String = "履歴を検索",
        onSearchChanged: ((String) -> Void)? = nil,
        showSearchCount: Bool = false,
        searchCount: Int = 0
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearchChanged = onSearchChanged
        self.showSearchCount = showSearchCount
        self.searchCount = searchCount
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .onChange(of: text) { oldValue, newValue in
                        onSearchChanged?(newValue)
                    }
                
                if showSearchCount && !text.isEmpty {
                    Text("\(searchCount)件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                        onSearchChanged?("")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                    .help("検索をクリア")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(6)
            
            // 検索候補やフィルターヒント
            if !text.isEmpty && text.count < 2 {
                HStack {
                    Text("さらに入力すると検索精度が向上します")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}