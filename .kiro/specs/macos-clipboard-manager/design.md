# デザイン文書

## 概要

SwiftUIを使用してmacOS用のクリップボード管理ツールを開発します。このアプリは、NSPasteboardを使用してクリップボードの変更を監視し、履歴を保存・管理する機能を提供します。MenuBarExtraを使用してメニューバーに常駐し、グローバルホットキーで素早くアクセスできるユーティリティアプリとして設計します。

## アーキテクチャ

### SPMパッケージ構成

```
ClipboardManager (メインアプリ)
├── ClipboardCore (ローカルSPMパッケージ)
│   ├── Models
│   ├── Services  
│   ├── Utilities
│   └── Tests
├── ClipboardUI (ローカルSPMパッケージ)
│   ├── Views
│   ├── ViewModels
│   ├── Components
│   └── Tests
└── ClipboardSecurity (ローカルSPMパッケージ)
    ├── Encryption
    ├── KeychainManager
    ├── PrivacyManager
    └── Tests
```

### 全体構成

```
┌─────────────────────────────────────────────────────────────┐
│                    App Layer (Main Target)                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   MenuBarExtra  │  │  Settings View  │  │ History View │ │
│  │   (ClipboardUI) │  │  (ClipboardUI)  │  │(ClipboardUI) │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                Service Layer (ClipboardCore)                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Clipboard       │  │ Smart Content   │  │ Search       │ │
│  │ Monitor Service │  │ Recognition     │  │ Manager      │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│              Data & Security Layer                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ SwiftData       │  │ Keychain        │  │ CloudKit     │ │
│  │ (ClipboardCore) │  │(ClipboardSec.)  │  │(ClipboardCore│ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### パッケージ依存関係

```
ClipboardManager App
├── depends on: ClipboardUI
├── depends on: ClipboardCore  
└── depends on: ClipboardSecurity

ClipboardUI
├── depends on: ClipboardCore
└── depends on: ClipboardSecurity

ClipboardCore
└── depends on: ClipboardSecurity

ClipboardSecurity
└── (no dependencies - 基盤パッケージ)
```

### SwiftUI App構造

```swift
import SwiftUI
import SwiftData
import ClipboardCore
import ClipboardUI
import ClipboardSecurity

@main
struct ClipboardManagerApp: App {
    let clipboardManager = ClipboardManager()
    let settingsManager = SettingsManager()
    let securityManager = SecurityManager()
    
    var body: some Scene {
        MenuBarExtra("Clipboard Manager", systemImage: "doc.on.clipboard") {
            ClipboardHistoryView()
                .environment(clipboardManager)
                .environment(settingsManager)
                .environment(securityManager)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(for: [ClipboardItemModel.self])
        
        Settings {
            SettingsView()
                .environment(settingsManager)
                .environment(securityManager)
        }
    }
}
```

### パッケージ構成詳細

#### ClipboardCore パッケージ
```swift
// Package.swift
let package = Package(
    name: "ClipboardCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ClipboardCore", targets: ["ClipboardCore"])
    ],
    dependencies: [
        .package(path: "../ClipboardSecurity")
    ],
    targets: [
        .target(
            name: "ClipboardCore",
            dependencies: ["ClipboardSecurity"]
        ),
        .testTarget(
            name: "ClipboardCoreTests",
            dependencies: ["ClipboardCore"]
        )
    ]
)
```

#### ClipboardUI パッケージ
```swift
// Package.swift
let package = Package(
    name: "ClipboardUI",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ClipboardUI", targets: ["ClipboardUI"])
    ],
    dependencies: [
        .package(path: "../ClipboardCore"),
        .package(path: "../ClipboardSecurity")
    ],
    targets: [
        .target(
            name: "ClipboardUI",
            dependencies: ["ClipboardCore", "ClipboardSecurity"]
        ),
        .testTarget(
            name: "ClipboardUITests",
            dependencies: ["ClipboardUI"]
        )
    ]
)
```

#### ClipboardSecurity パッケージ
```swift
// Package.swift
let package = Package(
    name: "ClipboardSecurity",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ClipboardSecurity", targets: ["ClipboardSecurity"])
    ],
    dependencies: [
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "20.0.0")
    ],
    targets: [
        .target(
            name: "ClipboardSecurity",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift")
            ]
        ),
        .testTarget(
            name: "ClipboardSecurityTests",
            dependencies: ["ClipboardSecurity"]
        )
    ]
)
```

## コンポーネントと インターフェース

### 1. クリップボード監視システム

#### ClipboardMonitorService
```swift
import Observation
import SwiftData

@Observable
@MainActor
class ClipboardMonitorService {
    private let pasteboard = NSPasteboard.general
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let modelContext: ModelContext
    
    var clipboardItems: [ClipboardItemModel] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task { @MainActor in
                await self.checkForClipboardChanges()
            }
        }
    }
    
    private func checkForClipboardChanges() async {
        let currentChangeCount = pasteboard.changeCount
        if currentChangeCount != lastChangeCount {
            await processClipboardChange()
            lastChangeCount = currentChangeCount
        }
    }
    
    private func processClipboardChange() async {
        // SwiftDataを使用してデータを永続化
        let newItem = ClipboardItemModel(from: pasteboard)
        modelContext.insert(newItem)
        try? modelContext.save()
        
        // メモリ内のアイテムリストを更新
        clipboardItems.insert(newItem, at: 0)
    }
}
```

#### ClipboardItem データモデル
```swift
import SwiftData
import Foundation

@Model
class ClipboardItemModel {
    @Attribute(.unique) var id: UUID
    var contentData: Data
    var contentType: ClipboardContentType
    var timestamp: Date
    var isFavorite: Bool
    var category: String?
    var preview: String
    var isEncrypted: Bool
    
    init(id: UUID = UUID(), 
         contentData: Data, 
         contentType: ClipboardContentType, 
         timestamp: Date = Date(),
         isFavorite: Bool = false,
         category: String? = nil,
         preview: String = "",
         isEncrypted: Bool = false) {
        self.id = id
        self.contentData = contentData
        self.contentType = contentType
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.category = category
        self.preview = preview
        self.isEncrypted = isEncrypted
    }
    
    convenience init(from pasteboard: NSPasteboard) {
        let (data, type, preview) = Self.extractContent(from: pasteboard)
        self.init(contentData: data, contentType: type, preview: preview)
    }
    
    private static func extractContent(from pasteboard: NSPasteboard) -> (Data, ClipboardContentType, String) {
        // NSPasteboardからコンテンツを抽出する実装
        if let string = pasteboard.string(forType: .string) {
            let data = string.data(using: .utf8) ?? Data()
            let type = SmartContentRecognizer.detectContentType(string)
            return (data, type, String(string.prefix(100)))
        } else if let imageData = pasteboard.data(forType: .png) ?? pasteboard.data(forType: .jpeg) {
            return (imageData, .image, "画像 (\(ByteCountFormatter().string(fromByteCount: Int64(imageData.count))))")
        }
        return (Data(), .text, "")
    }
}

enum ClipboardContentType: String, CaseIterable, Codable {
    case text, image, url, email, phoneNumber, colorCode, code, richText
    
    var systemImage: String {
        switch self {
        case .text: return "doc.text"
        case .image: return "photo"
        case .url: return "link"
        case .email: return "envelope"
        case .phoneNumber: return "phone"
        case .colorCode: return "paintpalette"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .richText: return "textformat"
        }
    }
}
```

### 2. グローバルホットキー管理

#### HotkeyManager
```swift
import Carbon
import Observation

@Observable
class HotkeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4B4D), id: 1)
    
    var isHotkeyRegistered: Bool = false
    var onHotkeyPressed: (() -> Void)?
    
    func registerHotkey(keyCode: UInt32, modifiers: UInt32) async throws {
        await MainActor.run {
            unregisterHotkey()
            
            let eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                        eventKind: OSType(kEventHotKeyPressed))
            
            let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID, 
                                           GetApplicationEventTarget(), 0, &hotKeyRef)
            
            if status == noErr {
                isHotkeyRegistered = true
                installEventHandler()
            } else {
                throw ClipboardManagerError.hotkeyRegistrationFailed
            }
        }
    }
    
    func unregisterHotkey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
            isHotkeyRegistered = false
        }
    }
    
    private func installEventHandler() {
        // Carbon Event Handlerの設定
        let eventHandler: EventHandlerUPP = { (nextHandler, theEvent, userData) -> OSStatus in
            let hotkeyManager = Unmanaged<HotkeyManager>.fromOpaque(userData!).takeUnretainedValue()
            hotkeyManager.onHotkeyPressed?()
            return noErr
        }
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                     eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), eventHandler, 1, &eventType,
                          Unmanaged.passUnretained(self).toOpaque(), nil)
    }
}
```

### 3. スマートコンテンツ認識

#### SmartContentRecognizer
```swift
import RegexBuilder
import AppKit

struct SmartContentRecognizer {
    static func analyzeContent(_ text: String) async -> [SmartAction] {
        await withTaskGroup(of: [SmartAction].self) { group in
            var allActions: [SmartAction] = []
            
            // 並列でコンテンツ分析を実行
            group.addTask { await detectURLs(in: text) }
            group.addTask { await detectEmails(in: text) }
            group.addTask { await detectPhoneNumbers(in: text) }
            group.addTask { await detectColorCodes(in: text) }
            group.addTask { await detectCode(in: text) }
            
            for await actions in group {
                allActions.append(contentsOf: actions)
            }
            
            return allActions
        }
    }
    
    static func detectContentType(_ text: String) -> ClipboardContentType {
        // RegexBuilderを使用したモダンな正規表現
        let urlRegex = Regex {
            "http"
            Optionally("s")
            "://"
            OneOrMore(.word)
        }
        
        let emailRegex = Regex {
            OneOrMore(.word)
            "@"
            OneOrMore(.word)
            "."
            OneOrMore(.word)
        }
        
        if text.contains(urlRegex) {
            return .url
        } else if text.contains(emailRegex) {
            return .email
        } else if detectColorCode(text) != nil {
            return .colorCode
        } else if isCodeLike(text) {
            return .code
        } else {
            return .text
        }
    }
    
    private static func detectURLs(in text: String) async -> [SmartAction] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        return matches?.compactMap { match in
            guard let url = match.url else { return nil }
            return .openURL(url)
        } ?? []
    }
    
    private static func detectEmails(in text: String) async -> [SmartAction] {
        let emailRegex = Regex {
            Capture {
                OneOrMore(.word)
                "@"
                OneOrMore(.word)
                "."
                OneOrMore(.word)
            }
        }
        
        return text.matches(of: emailRegex).map { match in
            .composeEmail(String(match.1))
        }
    }
    
    private static func detectPhoneNumbers(in text: String) async -> [SmartAction] {
        let phoneRegex = Regex {
            Optionally("+")
            Repeat(1...3) { .digit }
            Optionally("-")
            Repeat(3...4) { .digit }
            Optionally("-")
            Repeat(4...4) { .digit }
        }
        
        return text.matches(of: phoneRegex).map { match in
            .call(String(match.0))
        }
    }
    
    private static func detectColorCodes(in text: String) async -> [SmartAction] {
        let hexColorRegex = Regex {
            "#"
            Repeat(6) { .hexDigit }
        }
        
        return text.matches(of: hexColorRegex).compactMap { match in
            let colorString = String(match.0)
            if let color = NSColor(hex: colorString) {
                return .showColorPreview(color)
            }
            return nil
        }
    }
    
    private static func detectCode(in text: String) async -> [SmartAction] {
        if isCodeLike(text) {
            let language = detectProgrammingLanguage(text)
            return [.highlightCode(text, language: language)]
        }
        return []
    }
    
    private static func isCodeLike(_ text: String) -> Bool {
        let codeIndicators = ["{", "}", "function", "class", "import", "def", "var", "let", "const"]
        let indicatorCount = codeIndicators.reduce(0) { count, indicator in
            count + (text.contains(indicator) ? 1 : 0)
        }
        return indicatorCount >= 2
    }
    
    private static func detectProgrammingLanguage(_ code: String) -> String {
        if code.contains("func ") || code.contains("var ") || code.contains("let ") {
            return "swift"
        } else if code.contains("function ") || code.contains("const ") || code.contains("=>") {
            return "javascript"
        } else if code.contains("def ") || code.contains("import ") {
            return "python"
        }
        return "plaintext"
    }
}

enum SmartAction: Identifiable {
    case openURL(URL)
    case composeEmail(String)
    case call(String)
    case showColorPreview(NSColor)
    case highlightCode(String, language: String)
    
    var id: String {
        switch self {
        case .openURL(let url): return "url_\(url.absoluteString)"
        case .composeEmail(let email): return "email_\(email)"
        case .call(let phone): return "phone_\(phone)"
        case .showColorPreview(let color): return "color_\(color.hexString)"
        case .highlightCode(let code, let language): return "code_\(language)_\(code.hashValue)"
        }
    }
    
    var title: String {
        switch self {
        case .openURL: return "URLを開く"
        case .composeEmail: return "メールを作成"
        case .call: return "電話をかける"
        case .showColorPreview: return "色を表示"
        case .highlightCode: return "コードをハイライト"
        }
    }
    
    var systemImage: String {
        switch self {
        case .openURL: return "safari"
        case .composeEmail: return "envelope"
        case .call: return "phone"
        case .showColorPreview: return "paintpalette"
        case .highlightCode: return "chevron.left.forwardslash.chevron.right"
        }
    }
}
```

### 4. UI コンポーネント

#### ClipboardHistoryView
```swift
import SwiftUI
import SwiftData

struct ClipboardHistoryView: View {
    @Environment(ClipboardManager.self) private var clipboardManager
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \ClipboardItemModel.timestamp, order: .reverse) 
    private var allItems: [ClipboardItemModel]
    
    @State private var searchText = ""
    @State private var selectedFilter: ContentFilter = .all
    
    private var filteredItems: [ClipboardItemModel] {
        let filtered = allItems.filter { item in
            if selectedFilter != .all && item.contentType != selectedFilter.contentType {
                return false
            }
            
            if !searchText.isEmpty {
                return item.preview.localizedCaseInsensitiveContains(searchText)
            }
            
            return true
        }
        
        return Array(filtered.prefix(100)) // パフォーマンスのため最大100件に制限
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
            FilterBar(selectedFilter: $selectedFilter)
            
            if filteredItems.isEmpty {
                ContentUnavailableView("クリップボード履歴が空です", 
                                     systemImage: "doc.on.clipboard",
                                     description: Text("何かをコピーすると、ここに表示されます"))
            } else {
                List(filteredItems) { item in
                    ClipboardItemRow(item: item)
                        .onTapGesture {
                            Task {
                                await clipboardManager.copyToClipboard(item)
                            }
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

enum ContentFilter: String, CaseIterable {
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
```

#### ClipboardItemRow
```swift
struct ClipboardItemRow: View {
    let item: ClipboardItem
    
    var body: some View {
        HStack {
            ContentTypeIcon(type: item.contentType)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.preview)
                    .lineLimit(2)
                    .font(.body)
                
                HStack {
                    Text(item.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            SmartActionsView(item: item)
        }
        .padding(.vertical, 4)
    }
}
```

## データモデル

### SwiftData スキーマ

```swift
import SwiftData

@Model
class ClipboardItemModel {
    @Attribute(.unique) var id: UUID
    var contentData: Data
    var contentType: ClipboardContentType
    var timestamp: Date
    var isFavorite: Bool
    var category: String?
    var preview: String
    var isEncrypted: Bool
    
    // 関連データ
    @Relationship(deleteRule: .cascade) var smartActions: [SmartActionModel] = []
    
    init(id: UUID = UUID(), 
         contentData: Data, 
         contentType: ClipboardContentType, 
         timestamp: Date = Date(),
         isFavorite: Bool = false,
         category: String? = nil,
         preview: String = "",
         isEncrypted: Bool = false) {
        self.id = id
        self.contentData = contentData
        self.contentType = contentType
        self.timestamp = timestamp
        self.isFavorite = isFavorite
        self.category = category
        self.preview = preview
        self.isEncrypted = isEncrypted
    }
}

@Model
class SmartActionModel {
    var id: String
    var actionType: String
    var title: String
    var systemImage: String
    var actionData: Data
    
    @Relationship(inverse: \ClipboardItemModel.smartActions) 
    var clipboardItem: ClipboardItemModel?
    
    init(id: String, actionType: String, title: String, systemImage: String, actionData: Data) {
        self.id = id
        self.actionType = actionType
        self.title = title
        self.systemImage = systemImage
        self.actionData = actionData
    }
}

@Model
class CategoryModel {
    @Attribute(.unique) var name: String
    var color: String
    var systemImage: String
    var createdAt: Date
    
    init(name: String, color: String = "blue", systemImage: String = "folder", createdAt: Date = Date()) {
        self.name = name
        self.color = color
        self.systemImage = systemImage
        self.createdAt = createdAt
    }
}
```

### CloudKit同期

```swift
import CloudKit
import SwiftData
import Observation

@Observable
class CloudKitSyncManager {
    private let container = CKContainer(identifier: "iCloud.com.yourapp.clipboardmanager")
    private let modelContext: ModelContext
    
    var syncStatus: SyncStatus = .idle
    var lastSyncDate: Date?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func syncClipboardHistory() async throws {
        syncStatus = .syncing
        
        do {
            let database = container.privateCloudDatabase
            
            // SwiftDataとCloudKitの統合を使用
            async let uploadTask = uploadLocalChanges(to: database)
            async let downloadTask = downloadRemoteChanges(from: database)
            
            let (uploadResult, downloadResult) = try await (uploadTask, downloadTask)
            
            syncStatus = .completed
            lastSyncDate = Date()
            
        } catch {
            syncStatus = .failed(error)
            throw error
        }
    }
    
    private func uploadLocalChanges(to database: CKDatabase) async throws -> Bool {
        // SwiftDataのPersistentHistoryを使用してローカル変更を検出
        let descriptor = FetchDescriptor<ClipboardItemModel>(
            predicate: #Predicate { $0.timestamp > (lastSyncDate ?? Date.distantPast) }
        )
        
        let changedItems = try modelContext.fetch(descriptor)
        
        for item in changedItems {
            let record = try await convertToCloudKitRecord(item)
            try await database.save(record)
        }
        
        return true
    }
    
    private func downloadRemoteChanges(from database: CKDatabase) async throws -> Bool {
        let query = CKQuery(recordType: "ClipboardItem", predicate: NSPredicate(value: true))
        let results = try await database.records(matching: query)
        
        for (recordID, result) in results.matchResults {
            switch result {
            case .success(let record):
                try await processRemoteRecord(record)
            case .failure(let error):
                print("Failed to fetch record \(recordID): \(error)")
            }
        }
        
        return true
    }
    
    private func convertToCloudKitRecord(_ item: ClipboardItemModel) async throws -> CKRecord {
        let record = CKRecord(recordType: "ClipboardItem", recordID: CKRecord.ID(recordName: item.id.uuidString))
        
        record["contentData"] = item.contentData
        record["contentType"] = item.contentType.rawValue
        record["timestamp"] = item.timestamp
        record["isFavorite"] = item.isFavorite
        record["category"] = item.category
        record["preview"] = item.preview
        record["isEncrypted"] = item.isEncrypted
        
        return record
    }
    
    private func processRemoteRecord(_ record: CKRecord) async throws {
        guard let contentData = record["contentData"] as? Data,
              let contentTypeString = record["contentType"] as? String,
              let contentType = ClipboardContentType(rawValue: contentTypeString),
              let timestamp = record["timestamp"] as? Date else {
            return
        }
        
        let item = ClipboardItemModel(
            id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
            contentData: contentData,
            contentType: contentType,
            timestamp: timestamp,
            isFavorite: record["isFavorite"] as? Bool ?? false,
            category: record["category"] as? String,
            preview: record["preview"] as? String ?? "",
            isEncrypted: record["isEncrypted"] as? Bool ?? false
        )
        
        modelContext.insert(item)
        try modelContext.save()
    }
}

enum SyncStatus: Equatable {
    case idle
    case syncing
    case completed
    case failed(Error)
    
    static func == (lhs: SyncStatus, rhs: SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.syncing, .syncing), (.completed, .completed):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
```

## エラーハンドリング

### エラー種別定義

```swift
enum ClipboardManagerError: LocalizedError {
    case clipboardAccessDenied
    case storageError(Error)
    case syncError(Error)
    case hotkeyRegistrationFailed
    case encryptionError
    
    var errorDescription: String? {
        switch self {
        case .clipboardAccessDenied:
            return "クリップボードへのアクセスが拒否されました"
        case .storageError(let error):
            return "データの保存に失敗しました: \(error.localizedDescription)"
        case .syncError(let error):
            return "同期に失敗しました: \(error.localizedDescription)"
        case .hotkeyRegistrationFailed:
            return "ホットキーの登録に失敗しました"
        case .encryptionError:
            return "データの暗号化に失敗しました"
        }
    }
}
```

### エラーハンドリング戦略

1. **ユーザーフレンドリーなエラーメッセージ**: 技術的な詳細を隠し、ユーザーが理解しやすい日本語メッセージを表示
2. **自動復旧**: 一時的なエラーの場合は自動的に再試行
3. **グレースフルデグラデーション**: 一部機能が利用できない場合でも、他の機能は継続して動作
4. **ログ記録**: デバッグ用の詳細なログを記録（ユーザーデータは除く）

## テスト戦略とTDD開発フロー

### TDD開発フロー
```
1. Red: テストを書く (swift test で失敗確認)
2. Green: 最小限の実装 (swift test で成功確認) 
3. Refactor: リファクタリング (swift test で回帰確認)
```

### パッケージ別テスト戦略

#### ClipboardCore (ビジネスロジック)
- **高速実行**: シミュレータ不要、純粋なSwiftコード
- **TDD最適**: ロジックの変更に対する即座のフィードバック
- **モック活用**: NSPasteboardなどのシステム依存部分をモック化

#### ClipboardSecurity (セキュリティ)
- **独立テスト**: 他のモジュールに依存しない
- **暗号化テスト**: 暗号化・復号化の正確性を検証
- **Keychainテスト**: 実際のKeychainを使用した統合テスト

#### ClipboardUI (UI層)
- **ViewModelテスト**: UIロジックの単体テスト
- **SwiftUIプレビュー**: 視覚的な確認とプロトタイピング
- **アクセシビリティテスト**: VoiceOverなどの対応確認

### テスト実行パフォーマンス比較

```
従来のアプローチ (シミュレータ必要):
├── テスト起動時間: 10-15秒
├── テスト実行時間: 30-60秒
└── 総時間: 40-75秒

SPMパッケージアプローチ:
├── テスト起動時間: 1-2秒
├── テスト実行時間: 5-10秒  
└── 総時間: 6-12秒 (約85%短縮)
```

### SwiftTesting を使用したパッケージ別テスト

#### ClipboardCore パッケージのテスト
```swift
// ClipboardCore/Tests/ClipboardCoreTests/ClipboardMonitorServiceTests.swift
import Testing
import SwiftData
@testable import ClipboardCore

@Suite("ClipboardMonitorService Tests")
struct ClipboardMonitorServiceTests {
    
    @Test("クリップボード変更の検出")
    func clipboardChangeDetection() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context)
        
        // When - モックPasteboardを使用してテスト
        let mockPasteboard = MockPasteboard()
        mockPasteboard.setString("test", forType: .string)
        sut.setPasteboard(mockPasteboard)
        
        await sut.processClipboardChange()
        
        // Then
        #expect(sut.clipboardItems.count == 1)
        #expect(sut.clipboardItems.first?.preview.contains("test") == true)
    }
    
    @Test("重複コンテンツの処理")
    func duplicateContentHandling() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardMonitorService(modelContext: context)
        let mockPasteboard = MockPasteboard()
        sut.setPasteboard(mockPasteboard)
        
        // When
        mockPasteboard.setString("duplicate", forType: .string)
        await sut.processClipboardChange()
        await sut.processClipboardChange() // 同じ内容を再度処理
        
        // Then
        #expect(sut.clipboardItems.count == 1, "重複コンテンツは1つのアイテムとして処理される")
    }
}

@Suite("SmartContentRecognizer Tests")
struct SmartContentRecognizerTests {
    
    @Test("URL検出", arguments: [
        "https://www.apple.com",
        "http://example.com",
        "Visit https://github.com for code"
    ])
    func urlDetection(text: String) async throws {
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let urlActions = actions.compactMap { action in
            if case .openURL = action { return action }
            return nil
        }
        #expect(urlActions.count > 0, "URLが検出される")
    }
    
    @Test("メールアドレス検出")
    func emailDetection() async throws {
        // Given
        let text = "Contact me at user@example.com for more info"
        
        // When
        let actions = await SmartContentRecognizer.analyzeContent(text)
        
        // Then
        let emailActions = actions.compactMap { action in
            if case .composeEmail = action { return action }
            return nil
        }
        #expect(emailActions.count == 1, "メールアドレスが検出される")
    }
}

@Suite("SearchManager Tests")
struct SearchManagerTests {
    
    @Test("検索インデックス構築")
    func searchIndexBuilding() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        // テストデータを追加
        let item1 = ClipboardItemModel(contentData: "Hello World".data(using: .utf8)!, 
                                     contentType: .text, preview: "Hello World")
        let item2 = ClipboardItemModel(contentData: "Swift Programming".data(using: .utf8)!, 
                                     contentType: .text, preview: "Swift Programming")
        
        context.insert(item1)
        context.insert(item2)
        try context.save()
        
        // When
        await sut.buildSearchIndex()
        
        // Then
        let results = await sut.search(query: "Hello")
        #expect(results.count == 1)
        #expect(results.first?.preview == "Hello World")
    }
    
    @Test("あいまい検索")
    func fuzzySearch() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = SearchManager(modelContext: context)
        
        let item = ClipboardItemModel(contentData: "SwiftUI Development".data(using: .utf8)!, 
                                    contentType: .text, preview: "SwiftUI Development")
        context.insert(item)
        try context.save()
        
        // When - タイポを含む検索
        let results = await sut.search(query: "SwiftUi Develop")
        
        // Then
        #expect(results.count > 0, "あいまい検索で結果が見つかる")
    }
}
```

#### ClipboardSecurity パッケージのテスト
```swift
// ClipboardSecurity/Tests/ClipboardSecurityTests/SecurityManagerTests.swift
import Testing
@testable import ClipboardSecurity

@Suite("SecurityManager Tests")
struct SecurityManagerTests {
    
    @Test("機密データ検出")
    func sensitiveDataDetection() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("password: secret123") == true)
        #expect(sut.detectSensitiveContent("パスワード: abc123") == true)
        #expect(sut.detectSensitiveContent("Hello World") == false)
    }
    
    @Test("データ暗号化")
    func dataEncryption() async throws {
        // Given
        let sut = SecurityManager()
        let originalData = "Sensitive Information".data(using: .utf8)!
        
        // When
        let encryptedData = try await sut.encrypt(originalData)
        let decryptedData = try await sut.decrypt(encryptedData)
        
        // Then
        #expect(encryptedData != originalData, "データが暗号化される")
        #expect(decryptedData == originalData, "データが正しく復号化される")
    }
}

@Suite("KeychainManager Tests")
struct KeychainManagerTests {
    
    @Test("Keychainへの保存と取得")
    func keychainStorageAndRetrieval() async throws {
        // Given
        let sut = KeychainManager()
        let testKey = "test_key_\(UUID().uuidString)"
        let testValue = "test_value"
        
        // When
        try sut.store(testValue, forKey: testKey)
        let retrievedValue = sut.retrieve(forKey: testKey)
        
        // Then
        #expect(retrievedValue == testValue, "Keychainから正しい値が取得される")
        
        // Cleanup
        sut.delete(forKey: testKey)
    }
}
```

#### ClipboardUI パッケージのテスト
```swift
// ClipboardUI/Tests/ClipboardUITests/ViewModelTests.swift
import Testing
import SwiftData
@testable import ClipboardUI
@testable import ClipboardCore

@Suite("ClipboardHistoryViewModel Tests")
struct ClipboardHistoryViewModelTests {
    
    @Test("フィルタリング機能")
    func filteringFunctionality() async throws {
        // Given
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ClipboardItemModel.self, configurations: config)
        let context = ModelContext(container)
        
        let sut = ClipboardHistoryViewModel(modelContext: context)
        
        // テストデータを追加
        let textItem = ClipboardItemModel(contentData: "Text".data(using: .utf8)!, 
                                        contentType: .text, preview: "Text")
        let imageItem = ClipboardItemModel(contentData: Data(), 
                                         contentType: .image, preview: "Image")
        
        context.insert(textItem)
        context.insert(imageItem)
        try context.save()
        
        // When
        sut.selectedFilter = .text
        let filteredItems = await sut.getFilteredItems()
        
        // Then
        #expect(filteredItems.count == 1)
        #expect(filteredItems.first?.contentType == .text)
    }
}
```

### テスト実行コマンド

```bash
# 各パッケージで個別にテスト実行（高速）
cd ClipboardCore && swift test
cd ClipboardSecurity && swift test  
cd ClipboardUI && swift test

# 並列実行でさらに高速化
swift test --parallel

# 特定のテストスイートのみ実行
swift test --filter SmartContentRecognizerTests
```

### UI テスト

```swift
class ClipboardManagerUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }
    
    func testMenuBarExtraInteraction() {
        // メニューバーアイコンをクリック
        let menuBarExtra = app.menuBarExtraItems.firstMatch
        menuBarExtra.click()
        
        // 履歴ウィンドウが表示されることを確認
        XCTAssertTrue(app.windows["ClipboardHistory"].exists)
    }
}
```

### パフォーマンステスト

```swift
class PerformanceTests: XCTestCase {
    func testClipboardMonitoringPerformance() {
        let clipboardService = ClipboardMonitorService()
        
        measure {
            clipboardService.processLargeClipboardContent()
        }
    }
    
    func testSearchPerformance() {
        let historyManager = ClipboardHistoryManager()
        historyManager.loadTestData(count: 10000)
        
        measure {
            let results = historyManager.search(query: "test")
            XCTAssertNotNil(results)
        }
    }
}
```

## セキュリティ考慮事項

### データ暗号化

```swift
class SecureStorageManager {
    private let keychain = KeychainSwift()
    
    func storeSecureContent(_ content: String, forKey key: String) throws {
        // 機密データはKeychainに暗号化して保存
        keychain.set(content, forKey: key, withAccess: .accessibleWhenUnlocked)
    }
    
    func detectSensitiveContent(_ text: String) -> Bool {
        // パスワードパターンの検出
        let passwordPatterns = [
            "password\\s*[:=]\\s*\\S+",
            "pwd\\s*[:=]\\s*\\S+",
            "パスワード\\s*[:=]\\s*\\S+"
        ]
        
        return passwordPatterns.contains { pattern in
            text.range(of: pattern, options: .regularExpression) != nil
        }
    }
}
```

### プライバシー保護

1. **アクセス権限の管理**: アクセシビリティ権限の適切な要求と説明
2. **データの最小化**: 必要最小限のデータのみを保存
3. **自動削除**: 設定された期間後の自動データ削除
4. **プライベートモード**: 一時的な履歴記録停止機能

## パフォーマンス最適化

### メモリ管理

```swift
import Observation
import SwiftData

@Observable
class ClipboardHistoryManager {
    private let modelContext: ModelContext
    private let maxItems = 1000
    private let imageCompressionQuality: CGFloat = 0.7
    
    var memoryUsage: Int64 = 0
    var maxMemoryUsage: Int64 = 100 * 1024 * 1024 // 100MB
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addItem(_ item: ClipboardItemModel) async {
        // 非同期でアイテムを最適化
        let optimizedItem = await optimizeItem(item)
        
        await MainActor.run {
            modelContext.insert(optimizedItem)
            
            // メモリ使用量チェック
            Task {
                await enforceMemoryLimits()
            }
        }
    }
    
    private func optimizeItem(_ item: ClipboardItemModel) async -> ClipboardItemModel {
        if item.contentType == .image {
            let compressedData = await compressImageData(item.contentData, quality: imageCompressionQuality)
            item.contentData = compressedData
        }
        return item
    }
    
    private func compressImageData(_ data: Data, quality: CGFloat) async -> Data {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                guard let image = NSImage(data: data),
                      let tiffData = image.tiffRepresentation,
                      let bitmapRep = NSBitmapImageRep(data: tiffData),
                      let compressedData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality]) else {
                    continuation.resume(returning: data)
                    return
                }
                continuation.resume(returning: compressedData)
            }
        }
    }
    
    private func enforceMemoryLimits() async {
        let descriptor = FetchDescriptor<ClipboardItemModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        guard let allItems = try? modelContext.fetch(descriptor) else { return }
        
        // アイテム数制限
        if allItems.count > maxItems {
            let itemsToDelete = Array(allItems.dropFirst(maxItems))
            for item in itemsToDelete {
                modelContext.delete(item)
            }
        }
        
        // メモリ使用量制限
        var currentMemoryUsage: Int64 = 0
        var itemsToKeep: [ClipboardItemModel] = []
        
        for item in allItems {
            let itemSize = Int64(item.contentData.count)
            if currentMemoryUsage + itemSize <= maxMemoryUsage {
                currentMemoryUsage += itemSize
                itemsToKeep.append(item)
            } else {
                modelContext.delete(item)
            }
        }
        
        memoryUsage = currentMemoryUsage
        
        try? modelContext.save()
    }
}
```

### 検索最適化

```swift
import Observation
import SwiftData
import NaturalLanguage

@Observable
class SearchManager {
    private let modelContext: ModelContext
    private var searchIndex: [String: Set<UUID>] = [:]
    private let tokenizer = NLTokenizer(unit: .word)
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await buildSearchIndex()
        }
    }
    
    func search(query: String) async -> [ClipboardItemModel] {
        if query.isEmpty {
            return await fetchRecentItems()
        }
        
        // 複数の検索戦略を並列実行
        async let exactMatches = searchExact(query: query)
        async let fuzzyMatches = searchFuzzy(query: query)
        async let indexMatches = searchIndex(query: query)
        
        let (exact, fuzzy, indexed) = await (exactMatches, fuzzyMatches, indexMatches)
        
        // 結果をマージして重複を除去
        var allResults: [ClipboardItemModel] = []
        var seenIDs: Set<UUID> = []
        
        // 優先順位: 完全一致 > インデックス検索 > あいまい検索
        for results in [exact, indexed, fuzzy] {
            for item in results {
                if !seenIDs.contains(item.id) {
                    allResults.append(item)
                    seenIDs.insert(item.id)
                }
            }
        }
        
        return Array(allResults.prefix(50)) // 最大50件に制限
    }
    
    private func searchExact(query: String) async -> [ClipboardItemModel] {
        let predicate = #Predicate<ClipboardItemModel> { item in
            item.preview.localizedStandardContains(query)
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func searchFuzzy(query: String) async -> [ClipboardItemModel] {
        let allItems = await fetchRecentItems(limit: 1000)
        
        return await withTaskGroup(of: (ClipboardItemModel, Double)?.self) { group in
            for item in allItems {
                group.addTask {
                    let similarity = self.calculateSimilarity(query: query, text: item.preview)
                    return similarity > 0.3 ? (item, similarity) : nil
                }
            }
            
            var results: [(ClipboardItemModel, Double)] = []
            for await result in group {
                if let result = result {
                    results.append(result)
                }
            }
            
            return results
                .sorted { $0.1 > $1.1 } // 類似度でソート
                .map { $0.0 }
        }
    }
    
    private func searchIndex(query: String) async -> [ClipboardItemModel] {
        let keywords = extractKeywords(from: query)
        var matchingIDs: Set<UUID> = []
        
        for keyword in keywords {
            if let ids = searchIndex[keyword.lowercased()] {
                if matchingIDs.isEmpty {
                    matchingIDs = ids
                } else {
                    matchingIDs = matchingIDs.intersection(ids)
                }
            }
        }
        
        let predicate = #Predicate<ClipboardItemModel> { item in
            matchingIDs.contains(item.id)
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func buildSearchIndex() async {
        let allItems = await fetchRecentItems(limit: 10000)
        
        await withTaskGroup(of: (UUID, [String]).self) { group in
            for item in allItems {
                group.addTask {
                    let keywords = self.extractKeywords(from: item.preview)
                    return (item.id, keywords)
                }
            }
            
            var newIndex: [String: Set<UUID>] = [:]
            for await (itemID, keywords) in group {
                for keyword in keywords {
                    let key = keyword.lowercased()
                    newIndex[key, default: Set()].insert(itemID)
                }
            }
            
            await MainActor.run {
                self.searchIndex = newIndex
            }
        }
    }
    
    private func extractKeywords(from text: String) -> [String] {
        tokenizer.string = text
        var keywords: [String] = []
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            let token = String(text[tokenRange])
            if token.count > 2 && !token.allSatisfy(\.isWhitespace) {
                keywords.append(token)
            }
            return true
        }
        
        return keywords
    }
    
    private func calculateSimilarity(query: String, text: String) -> Double {
        let queryWords = Set(query.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let textWords = Set(text.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        let intersection = queryWords.intersection(textWords)
        let union = queryWords.union(textWords)
        
        return union.isEmpty ? 0.0 : Double(intersection.count) / Double(union.count)
    }
    
    private func fetchRecentItems(limit: Int = 100) async -> [ClipboardItemModel] {
        let descriptor = FetchDescriptor<ClipboardItemModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
```

## 国際化対応

### 多言語サポート

```swift
// Localizable.strings (Japanese)
"clipboard.empty" = "クリップボード履歴が空です";
"clipboard.item.copied" = "クリップボードにコピーしました";
"settings.hotkey.title" = "ホットキー設定";
"settings.history.limit" = "履歴保存数";

// SwiftUIでの使用
Text("clipboard.empty")
    .font(.body)
    .foregroundColor(.secondary)
```

### 日付・時刻のローカライゼーション

```swift
extension Date {
    func localizedRelativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.current
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
```

## App Store配布準備

### Info.plist設定

```xml
<key>NSHumanReadableCopyright</key>
<string>© 2024 Your Company. All rights reserved.</string>

<key>LSUIElement</key>
<true/>

<key>NSAccessibilityUsageDescription</key>
<string>このアプリはクリップボードの変更を監視するためにアクセシビリティ権限が必要です。</string>

<key>NSAppleEventsUsageDescription</key>
<string>グローバルホットキー機能のためにAppleEventsへのアクセスが必要です。</string>
```

### サンドボックス設定

```xml
<key>com.apple.security.app-sandbox</key>
<true/>

<key>com.apple.security.files.user-selected.read-write</key>
<true/>

<key>com.apple.security.network.client</key>
<true/>
```

### アプリアイコンとメタデータ

- 1024x1024のアプリアイコン（App Store用）
- 各種サイズのアイコン（16x16から512x512）
- メニューバー用のテンプレートアイコン
- アプリの説明文（日本語・英語）
- スクリーンショット（macOS用）
- プライバシーポリシー
- 利用規約