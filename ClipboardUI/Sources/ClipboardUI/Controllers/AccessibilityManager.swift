import SwiftUI
import Observation

// MARK: - Accessibility Types and Protocols

public enum AccessibilityElement: Equatable {
    case clipboardItem
    case searchField
    case settingsButton
    case clipboardList
    case actionButton(String)
    
    public static func == (lhs: AccessibilityElement, rhs: AccessibilityElement) -> Bool {
        switch (lhs, rhs) {
        case (.clipboardItem, .clipboardItem),
             (.searchField, .searchField),
             (.settingsButton, .settingsButton),
             (.clipboardList, .clipboardList):
            return true
        case let (.actionButton(lhsString), .actionButton(rhsString)):
            return lhsString == rhsString
        default:
            return false
        }
    }
}

public enum AccessibilityNotificationType {
    case screenChanged
    case announcement
    case layoutChanged
}

public enum ContentType {
    case text
    case image
    case url
    case email
    case phoneNumber
    case colorCode
    case code
    case richText
    
    var localizedDescription: String {
        switch self {
        case .text: return "テキスト"
        case .image: return "画像"
        case .url: return "URL"
        case .email: return "メールアドレス"
        case .phoneNumber: return "電話番号"
        case .colorCode: return "カラーコード"
        case .code: return "コード"
        case .richText: return "リッチテキスト"
        }
    }
}

// MARK: - AccessibilityAction

public struct AccessibilityActionInfo {
    public let name: String
    public let action: () -> Void
    
    public init(name: String, action: @escaping () -> Void) {
        self.name = name
        self.action = action
    }
}

// MARK: - AccessibilityManager

extension Controllers {
    @MainActor
    @Observable
    public class AccessibilityManager: @unchecked Sendable {
        
        // MARK: - Public Properties
        public var isVoiceOverRunning: Bool = false
        public var keyboardNavigationEnabled: Bool = true
        public var screenReaderEnabled: Bool = false
        public var isHighContrastEnabled: Bool = false
        
        // MARK: - Private Properties
        private var speechRate: Float = 0.5
        private var currentDynamicTypeSize: DynamicTypeSize = .large
        
        // MARK: - Initialization
        public init() {
            updateAccessibilitySettings()
            setupAccessibilityNotifications()
        }
        
        // MARK: - Public Methods
        
        /// VoiceOver用ラベル生成
        public func generateVoiceOverLabel(
            contentType: ContentType,
            preview: String,
            timestamp: Date
        ) -> String {
            let typeDescription = contentType.localizedDescription
            let timeDescription = formatTimeForVoiceOver(timestamp)
            let previewText = cleanPreviewForVoiceOver(preview)
            
            return "\(typeDescription)アイテム。\(previewText)。\(timeDescription)"
        }
        
        /// VoiceOverヒント生成
        public func generateVoiceOverHint(for element: AccessibilityElement) -> String {
            switch element {
            case .clipboardItem:
                return "ダブルタップでクリップボードにコピー"
            case .searchField:
                return "クリップボード履歴を検索"
            case .settingsButton:
                return "設定画面を開く"
            case .clipboardList:
                return "クリップボード履歴一覧"
            case .actionButton(let actionName):
                return "ダブルタップで\(actionName)"
            }
        }
        
        /// キーボードナビゲーション設定
        public func setKeyboardNavigationEnabled(_ enabled: Bool) {
            keyboardNavigationEnabled = enabled
        }
        
        /// 要素ナビゲーション順序取得
        public func getElementNavigationOrder() -> [AccessibilityElement] {
            return [
                .searchField,
                .clipboardList,
                .settingsButton
            ]
        }
        
        /// アクセシビリティアクション生成
        public func generateAccessibilityActions(
            for element: AccessibilityElement,
            canFavorite: Bool = false,
            canDelete: Bool = false
        ) -> [AccessibilityActionInfo] {
            var actions: [AccessibilityActionInfo] = []
            
            switch element {
            case .clipboardItem:
                actions.append(AccessibilityActionInfo(name: "コピー", action: {}))
                
                if canFavorite {
                    actions.append(AccessibilityActionInfo(name: "お気に入り", action: {}))
                }
                
                if canDelete {
                    actions.append(AccessibilityActionInfo(name: "削除", action: {}))
                }
                
            case .searchField:
                actions.append(AccessibilityActionInfo(name: "検索", action: {}))
                
            case .settingsButton:
                actions.append(AccessibilityActionInfo(name: "開く", action: {}))
                
            default:
                break
            }
            
            return actions
        }
        
        /// スケールされたフォントサイズ取得
        public func getScaledFontSize(_ originalSize: CGFloat) -> CGFloat {
            // Dynamic Type対応の基本的なスケーリング
            let scaleFactor = getAccessibilityScaleFactor()
            return originalSize * scaleFactor
        }
        
        /// 読み上げ速度設定
        public func setSpeechRate(_ rate: Float) {
            speechRate = max(0.1, min(1.0, rate))
        }
        
        /// 読み上げ速度取得
        public func getSpeechRate() -> Float {
            return speechRate
        }
        
        /// アクセシビリティ通知送信
        public func postAccessibilityNotification(
            _ type: AccessibilityNotificationType,
            argument: Any? = nil
        ) {
            #if os(macOS)
            // macOS用のアクセシビリティ通知
            switch type {
            case .screenChanged:
                if let app = NSApp {
                    NSAccessibility.post(element: app, notification: .applicationActivated)
                }
            case .announcement:
                if let message = argument as? String, let app = NSApp {
                    NSAccessibility.post(element: app, 
                                       notification: .announcementRequested, 
                                       userInfo: [.announcement: message])
                }
            case .layoutChanged:
                if let app = NSApp {
                    NSAccessibility.post(element: app, notification: .layoutChanged)
                }
            }
            #else
            // iOS用の実装（今後の拡張用）
            switch type {
            case .screenChanged:
                UIAccessibility.post(notification: .screenChanged, argument: argument)
            case .announcement:
                UIAccessibility.post(notification: .announcement, argument: argument)
            case .layoutChanged:
                UIAccessibility.post(notification: .layoutChanged, argument: argument)
            }
            #endif
        }
        
        // MARK: - Private Methods
        
        /// アクセシビリティ設定更新
        private func updateAccessibilitySettings() {
            #if os(macOS)
            // macOSでは基本的なアクセシビリティ設定を取得
            isVoiceOverRunning = false // 基本実装では無効
            isHighContrastEnabled = NSWorkspace.shared.accessibilityDisplayShouldIncreaseContrast
            screenReaderEnabled = isVoiceOverRunning
            #else
            isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
            isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled || 
                                   UIAccessibility.isReduceTransparencyEnabled
            screenReaderEnabled = isVoiceOverRunning
            #endif
        }
        
        /// アクセシビリティ通知設定
        private func setupAccessibilityNotifications() {
            #if os(macOS)
            // macOS用の通知監視
            NotificationCenter.default.addObserver(
                forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.updateAccessibilitySettings()
                }
            }
            #else
            // iOS用の通知監視（今後の拡張用）
            NotificationCenter.default.addObserver(
                forName: UIAccessibility.voiceOverStatusDidChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.updateAccessibilitySettings()
                }
            }
            #endif
        }
        
        /// VoiceOver用時刻フォーマット
        private func formatTimeForVoiceOver(_ date: Date) -> String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            formatter.locale = Locale.current
            return formatter.localizedString(for: date, relativeTo: Date())
        }
        
        /// VoiceOver用プレビューテキストクリーニング
        private func cleanPreviewForVoiceOver(_ preview: String) -> String {
            // 改行や特殊文字を適切に処理
            let cleaned = preview
                .replacingOccurrences(of: "\n", with: "。")
                .replacingOccurrences(of: "\t", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 長いテキストは切り詰める
            if cleaned.count > 100 {
                let index = cleaned.index(cleaned.startIndex, offsetBy: 97)
                return String(cleaned[..<index]) + "..."
            }
            
            return cleaned
        }
        
        /// アクセシビリティスケール係数取得
        private func getAccessibilityScaleFactor() -> CGFloat {
            #if os(macOS)
            // macOSのフォントサイズ設定に基づく
            return 1.0 // 基本実装
            #else
            // Dynamic Type対応
            switch UIApplication.shared.preferredContentSizeCategory {
            case .extraSmall: return 0.8
            case .small: return 0.9
            case .medium: return 1.0
            case .large: return 1.0
            case .extraLarge: return 1.2
            case .extraExtraLarge: return 1.3
            case .extraExtraExtraLarge: return 1.4
            case .accessibilityMedium: return 1.6
            case .accessibilityLarge: return 1.8
            case .accessibilityExtraLarge: return 2.0
            case .accessibilityExtraExtraLarge: return 2.2
            case .accessibilityExtraExtraExtraLarge: return 2.4
            default: return 1.0
            }
            #endif
        }
    }
}

// MARK: - SwiftUI View Modifiers

public struct AccessibilityEnhancedModifier: ViewModifier {
    let manager: Controllers.AccessibilityManager
    let element: AccessibilityElement
    let label: String
    let hint: String?
    
    public func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? manager.generateVoiceOverHint(for: element))
            .accessibilityElement(children: .combine)
    }
}

public extension View {
    /// アクセシビリティ強化修飾子
    func accessibilityEnhanced(
        _ manager: Controllers.AccessibilityManager,
        element: AccessibilityElement,
        label: String,
        hint: String? = nil
    ) -> some View {
        self.modifier(AccessibilityEnhancedModifier(
            manager: manager,
            element: element,
            label: label,
            hint: hint
        ))
    }
}

// MARK: - macOS Specific Extensions

