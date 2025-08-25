import SwiftUI

extension Views {
    public struct SettingsView: View {
        @State private var settingsManager = Models.SettingsManager()
        
        public init() {}
        
        public var body: some View {
            TabView {
                GeneralSettingsView(settingsManager: settingsManager)
                    .tabItem {
                        Image(systemName: "gear")
                        Text("一般")
                    }
                
                SecuritySettingsView(settingsManager: settingsManager)
                    .tabItem {
                        Image(systemName: "lock")
                        Text("セキュリティ")
                    }
            }
            .frame(width: 450, height: 350)
        }
    }
    
    public struct GeneralSettingsView: View {
        @Bindable var settingsManager: Models.SettingsManager
        
        public init(settingsManager: Models.SettingsManager) {
            self.settingsManager = settingsManager
        }
        
        public init() {
            self.settingsManager = Models.SettingsManager()
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("一般設定")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 16) {
                    // ホットキー設定
                    Views.HotkeySettingsView(settingsManager: settingsManager)
                    
                    Divider()
                    
                    // 履歴制限設定
                    HistoryLimitSettingsView(historyLimit: $settingsManager.historyLimit)
                    
                    Divider()
                    
                    // 外観設定
                    AppearanceSettingsView(appearance: $settingsManager.appearance)
                    
                    Divider()
                    
                    // 自動起動設定
                    AutoStartSettingsView(autoStart: $settingsManager.autoStart)
                    
                    Divider()
                    
                    // コンテンツタイプ設定
                    ContentTypeSettingsView(contentTypes: $settingsManager.contentTypes)
                }
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    public struct SecuritySettingsView: View {
        @Bindable var settingsManager: Models.SettingsManager
        
        public init(settingsManager: Models.SettingsManager) {
            self.settingsManager = settingsManager
        }
        
        public init() {
            self.settingsManager = Models.SettingsManager()
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("セキュリティ設定")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 16) {
                    // プライベートモード設定
                    PrivateModeSettingsView(privateMode: $settingsManager.privateMode)
                    
                    Divider()
                    
                    // 自動ロック設定
                    AutoLockSettingsView(autoLockMinutes: $settingsManager.autoLockMinutes)
                }
                
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Settings Components

struct HistoryLimitSettingsView: View {
    @Binding var historyLimit: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("履歴保存数", systemImage: "list.number")
                .font(.headline)
            
            HStack {
                Slider(
                    value: Binding(
                        get: { Double(historyLimit) },
                        set: { historyLimit = Int($0) }
                    ),
                    in: 10...1000,
                    step: 10
                ) {
                    Text("履歴保存数")
                } minimumValueLabel: {
                    Text("10")
                        .font(.caption)
                } maximumValueLabel: {
                    Text("1000")
                        .font(.caption)
                }
                
                Text("\\(historyLimit)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .frame(width: 40)
            }
            
            Text("保存するクリップボード履歴の最大数")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AppearanceSettingsView: View {
    @Binding var appearance: Models.AppearanceMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("外観", systemImage: "paintbrush")
                .font(.headline)
            
            Picker("外観モード", selection: $appearance) {
                ForEach(Models.AppearanceMode.allCases, id: \.self) { mode in
                    Text(mode.displayName)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            Text("アプリの外観テーマを設定")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AutoStartSettingsView: View {
    @Binding var autoStart: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("ログイン時に起動", systemImage: "power")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $autoStart)
                    .toggleStyle(.switch)
            }
            
            Text("macOS起動時に自動的にアプリを開始")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ContentTypeSettingsView: View {
    @Binding var contentTypes: Set<Models.ContentType>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("追跡するコンテンツタイプ", systemImage: "doc.on.clipboard")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Models.ContentType.allCases, id: \.self) { contentType in
                    HStack {
                        Image(systemName: contentType.systemImage)
                            .foregroundColor(.accentColor)
                        
                        Text(contentType.displayName)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { contentTypes.contains(contentType) },
                            set: { isEnabled in
                                if isEnabled {
                                    contentTypes.insert(contentType)
                                } else {
                                    contentTypes.remove(contentType)
                                }
                            }
                        ))
                        .toggleStyle(.checkbox)
                    }
                }
            }
            
            Text("クリップボードに保存するコンテンツの種類")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct PrivateModeSettingsView: View {
    @Binding var privateMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("プライベートモード", systemImage: "eye.slash")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $privateMode)
                    .toggleStyle(.switch)
            }
            
            Text("有効にすると、一時的にクリップボード履歴の記録を停止")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AutoLockSettingsView: View {
    @Binding var autoLockMinutes: Int
    
    private let lockOptions = [
        (0, "無効"),
        (5, "5分"),
        (10, "10分"),
        (15, "15分"),
        (30, "30分"),
        (60, "1時間")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("自動ロック", systemImage: "lock.fill")
                .font(.headline)
            
            Picker("自動ロック時間", selection: $autoLockMinutes) {
                ForEach(lockOptions, id: \.0) { minutes, label in
                    Text(label)
                        .tag(minutes)
                }
            }
            .pickerStyle(.menu)
            
            Text("指定時間後にクリップボード履歴へのアクセスをロック")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview("Settings") {
    Views.SettingsView()
}

#Preview("General Settings") {
    Views.GeneralSettingsView()
        .frame(width: 450, height: 350)
}

#Preview("Security Settings") {
    Views.SecuritySettingsView()
        .frame(width: 450, height: 350)
}