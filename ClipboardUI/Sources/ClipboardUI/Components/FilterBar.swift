import SwiftUI
import ClipboardCore

/// コンテンツタイプ別フィルタリング機能を提供するFilterBarコンポーネント
public struct FilterBar: View {
    @Binding var selectedFilter: ContentFilter
    var filters: [ContentFilter]
    var onFilterChanged: ((ContentFilter) -> Void)?
    
    public init(
        selectedFilter: Binding<ContentFilter>,
        filters: [ContentFilter] = ContentFilter.allCases,
        onFilterChanged: ((ContentFilter) -> Void)? = nil
    ) {
        self._selectedFilter = selectedFilter
        self.filters = filters
        self.onFilterChanged = onFilterChanged
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                        onFilterChanged?(filter)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: filter.systemImage)
                                .font(.caption)
                                .scaleEffect(selectedFilter == filter ? 1.1 : 1.0)
                            Text(filter.rawValue)
                                .font(.caption)
                                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedFilter == filter ? Color.accentColor : Color(.controlBackgroundColor))
                                .shadow(
                                    color: selectedFilter == filter ? Color.accentColor.opacity(0.3) : Color.clear,
                                    radius: selectedFilter == filter ? 2 : 0,
                                    x: 0,
                                    y: 1
                                )
                        )
                        .foregroundColor(selectedFilter == filter ? .white : .primary)
                        .scaleEffect(selectedFilter == filter ? 1.02 : 1.0)
                    }
                    .buttonStyle(.borderless)
                    .animation(.easeInOut(duration: 0.2), value: selectedFilter)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 6)
    }
}