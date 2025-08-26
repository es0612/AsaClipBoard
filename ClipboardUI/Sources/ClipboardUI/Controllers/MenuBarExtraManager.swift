import SwiftUI
import Observation
import ClipboardCore

@MainActor
@Observable
public class MenuBarExtraManager: @unchecked Sendable {
    // MARK: - Public Properties
    public var quickPreviewItems: [ClipboardItemModel] = []
    public var isMenuBarVisible: Bool = true
    public var statusMessage: String = "準備完了"
    
    // コールバック
    public var onShowWindow: (() -> Void)?
    public var onItemSelected: ((ClipboardItemModel) -> Void)?
    
    // MARK: - Private Properties
    private let maxQuickPreviewItems = 5
    
    // MARK: - Initialization
    public init() {
        // 初期化時は独自のステータスメッセージを設定
        statusMessage = "準備完了"
    }
    
    // MARK: - Public Methods
    
    /// クイックプレビューアイテムを更新
    public func updateQuickPreviewItems(_ items: [ClipboardItemModel]) {
        // 最大5個に制限
        self.quickPreviewItems = Array(items.prefix(maxQuickPreviewItems))
        updateStatusMessage()
    }
    
    /// メニューバーアイコンの表示/非表示を制御
    public func setMenuBarVisibility(_ isVisible: Bool) {
        self.isMenuBarVisible = isVisible
    }
    
    /// ウィンドウ表示をトリガー
    public func triggerShowWindow() {
        onShowWindow?()
    }
    
    /// アイテム選択をトリガー
    public func selectItem(_ item: ClipboardItemModel) {
        onItemSelected?(item)
    }
    
    // MARK: - Private Methods
    
    /// ステータスメッセージを更新
    private func updateStatusMessage() {
        if quickPreviewItems.isEmpty {
            statusMessage = "履歴なし"
        } else {
            statusMessage = "\(quickPreviewItems.count)個のアイテム"
        }
    }
}

// MARK: - MenuBarExtra Content Helper
public extension MenuBarExtraManager {
    
    /// メニューバー用のクイックプレビュービューを生成
    func makeQuickPreviewView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // ヘッダー
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .foregroundColor(.primary)
                Text("ClipBoard")
                    .font(.headline)
                Spacer()
                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            
            Divider()
            
            // クイックプレビューアイテム
            if quickPreviewItems.isEmpty {
                ContentUnavailableView {
                    Label("履歴なし", systemImage: "tray")
                } description: {
                    Text("クリップボードをコピーすると履歴が表示されます")
                }
                .frame(width: 300, height: 150)
            } else {
                VStack(spacing: 4) {
                    ForEach(quickPreviewItems) { item in
                        QuickPreviewRow(item: item) {
                            self.selectItem(item)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Divider()
            
            // フッター
            HStack {
                Button("すべて表示") {
                    self.triggerShowWindow()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("設定") {
                    self.openSettings()
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(width: 300)
    }
    
    /// 設定を開く
    private func openSettings() {
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}

// MARK: - Quick Preview Row Component
private struct QuickPreviewRow: View {
    let item: ClipboardItemModel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // コンテンツタイプアイコン
                Image(systemName: item.contentType.systemImage)
                    .foregroundColor(.secondary)
                    .frame(width: 16, height: 16)
                
                // プレビューテキスト
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.preview)
                        .font(.body)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(item.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // お気に入りアイコン
                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}