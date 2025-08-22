import SwiftUI
import ClipboardCore

/// コンテンツタイプに対応するアイコンを表示するSwiftUIビュー
public struct ContentTypeIcon: View {
    public let type: ClipboardContentType
    public let size: CGFloat
    
    public init(type: ClipboardContentType, size: CGFloat = 16) {
        self.type = type
        self.size = size
    }
    
    public var body: some View {
        Image(systemName: type.systemImage)
            .font(.system(size: size))
            .foregroundColor(.primary)
    }
}