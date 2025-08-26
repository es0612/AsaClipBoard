import SwiftUI
import AppKit

extension Views {
    public struct AppearanceSettingsView: View {
        @Bindable var settingsManager: Models.SettingsManager
        @State private var appearanceManager = Models.AppearanceManager()
        @State private var selectedCustomColor: Models.CustomColor?
        @State private var showingCustomColorEditor = false
        
        public init(settingsManager: Models.SettingsManager) {
            self.settingsManager = settingsManager
        }
        
        public var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("外観設定")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 16) {
                    // テーマ選択
                    ThemeSelectionView(
                        selectedTheme: $settingsManager.appearance,
                        appearanceManager: appearanceManager
                    )
                    
                    Divider()
                    
                    // カスタムカラーテーマ
                    CustomColorThemeView(
                        appearanceManager: appearanceManager,
                        selectedCustomColor: $selectedCustomColor,
                        showingCustomColorEditor: $showingCustomColorEditor
                    )
                    
                    Divider()
                    
                    // テーマプレビュー
                    ThemePreviewView(
                        currentTheme: settingsManager.appearance,
                        customColor: selectedCustomColor
                    )
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                // 設定管理の同期
                appearanceManager.setTheme(settingsManager.appearance)
                selectedCustomColor = appearanceManager.customColors
            }
            .onChange(of: settingsManager.appearance) { _, newValue in
                appearanceManager.setTheme(newValue)
            }
            .onChange(of: selectedCustomColor) { _, newValue in
                if let color = newValue {
                    appearanceManager.setCustomColors(color)
                }
            }
        }
    }
    
    private struct ThemeSelectionView: View {
        @Binding var selectedTheme: Models.AppearanceMode
        let appearanceManager: Models.AppearanceManager
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Label("外観テーマ", systemImage: "paintbrush")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    ForEach(Models.AppearanceMode.allCases, id: \.self) { theme in
                        ThemeOptionView(
                            theme: theme,
                            isSelected: selectedTheme == theme,
                            systemAppearance: appearanceManager.detectSystemAppearance()
                        )
                        .onTapGesture {
                            selectedTheme = theme
                        }
                    }
                }
                
                Text("アプリの外観テーマを選択してください")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private struct ThemeOptionView: View {
        let theme: Models.AppearanceMode
        let isSelected: Bool
        let systemAppearance: Models.AppearanceMode
        
        var body: some View {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                        .frame(width: 60, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? .blue : .gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                        )
                    
                    Image(systemName: systemImageName)
                        .font(.title2)
                        .foregroundColor(foregroundColor)
                }
                
                Text(theme.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
        
        private var backgroundColor: Color {
            switch theme {
            case .light:
                return .white
            case .dark:
                return .black
            case .system:
                return systemAppearance == .dark ? .black : .white
            }
        }
        
        private var foregroundColor: Color {
            switch theme {
            case .light:
                return .black
            case .dark:
                return .white
            case .system:
                return systemAppearance == .dark ? .white : .black
            }
        }
        
        private var systemImageName: String {
            switch theme {
            case .light:
                return "sun.max"
            case .dark:
                return "moon"
            case .system:
                return "gearshape"
            }
        }
    }
    
    private struct CustomColorThemeView: View {
        let appearanceManager: Models.AppearanceManager
        @Binding var selectedCustomColor: Models.CustomColor?
        @Binding var showingCustomColorEditor: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Label("カスタムカラーテーマ", systemImage: "paintpalette")
                    .font(.headline)
                
                HStack {
                    Text("現在のカスタムカラー:")
                        .foregroundColor(.secondary)
                    
                    if let customColor = selectedCustomColor {
                        HStack(spacing: 4) {
                            ColorDot(color: customColor.primary)
                            ColorDot(color: customColor.secondary)
                            ColorDot(color: customColor.accent)
                            ColorDot(color: customColor.background)
                            ColorDot(color: customColor.surface)
                        }
                    } else {
                        Text("なし")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    Button("編集...") {
                        showingCustomColorEditor = true
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    Button("デフォルト（ライト）") {
                        selectedCustomColor = Models.CustomColor.defaultLight
                    }
                    .buttonStyle(.bordered)
                    
                    Button("デフォルト（ダーク）") {
                        selectedCustomColor = Models.CustomColor.defaultDark
                    }
                    .buttonStyle(.bordered)
                    
                    if selectedCustomColor != nil {
                        Button("リセット") {
                            selectedCustomColor = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                Text("カスタムカラーテーマで外観をパーソナライズ")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .sheet(isPresented: $showingCustomColorEditor) {
                CustomColorEditorView(
                    customColor: $selectedCustomColor,
                    isPresented: $showingCustomColorEditor
                )
            }
        }
    }
    
    private struct ColorDot: View {
        let color: Color
        
        var body: some View {
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(.gray.opacity(0.3), lineWidth: 0.5)
                )
        }
    }
    
    private struct CustomColorEditorView: View {
        @Binding var customColor: Models.CustomColor?
        @Binding var isPresented: Bool
        
        @State private var primaryColor: Color = .blue
        @State private var secondaryColor: Color = .gray
        @State private var accentColor: Color = .blue
        @State private var backgroundColor: Color = .white
        @State private var surfaceColor: Color = Color.gray.opacity(0.1)
        
        var body: some View {
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("カスタムカラーテーマエディタ")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 16) {
                        ColorPickerRow(label: "プライマリ", color: $primaryColor)
                        ColorPickerRow(label: "セカンダリ", color: $secondaryColor)
                        ColorPickerRow(label: "アクセント", color: $accentColor)
                        ColorPickerRow(label: "背景", color: $backgroundColor)
                        ColorPickerRow(label: "サーフェス", color: $surfaceColor)
                    }
                    
                    // プレビュー
                    VStack(alignment: .leading, spacing: 8) {
                        Text("プレビュー")
                            .font(.headline)
                        
                        PreviewCard(
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            accentColor: accentColor,
                            backgroundColor: backgroundColor,
                            surfaceColor: surfaceColor
                        )
                    }
                    
                    Spacer()
                }
                .padding()
//                .navigationBarTitleDisplayMode(.inline) // macOS unavailable
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("キャンセル") {
                            isPresented = false
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存") {
                            let newCustomColor = Models.CustomColor(
                                primary: primaryColor,
                                secondary: secondaryColor,
                                accent: accentColor,
                                background: backgroundColor,
                                surface: surfaceColor
                            )
                            customColor = newCustomColor
                            isPresented = false
                        }
                    }
                }
            }
            .frame(width: 400, height: 500)
            .onAppear {
                if let existing = customColor {
                    primaryColor = existing.primary
                    secondaryColor = existing.secondary
                    accentColor = existing.accent
                    backgroundColor = existing.background
                    surfaceColor = existing.surface
                } else {
                    let defaultColor = Models.CustomColor.defaultLight
                    primaryColor = defaultColor.primary
                    secondaryColor = defaultColor.secondary
                    accentColor = defaultColor.accent
                    backgroundColor = defaultColor.background
                    surfaceColor = defaultColor.surface
                }
            }
        }
    }
    
    private struct ColorPickerRow: View {
        let label: String
        @Binding var color: Color
        
        var body: some View {
            HStack {
                Text(label)
                    .frame(width: 80, alignment: .leading)
                
                ColorPicker("", selection: $color)
                    .labelsHidden()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 40, height: 20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Spacer()
            }
        }
    }
    
    private struct PreviewCard: View {
        let primaryColor: Color
        let secondaryColor: Color
        let accentColor: Color
        let backgroundColor: Color
        let surfaceColor: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("サンプルアプリ")
                        .font(.headline)
                        .foregroundColor(primaryColor)
                    
                    Spacer()
                    
                    Button("アクション") {
                        // Preview only
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(.white)
                    .tint(accentColor)
                }
                
                Text("これはテキストのサンプルです。")
                    .foregroundColor(secondaryColor)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(surfaceColor)
                    .frame(height: 40)
                    .overlay(
                        Text("サーフェス要素")
                            .foregroundColor(primaryColor)
                    )
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private struct ThemePreviewView: View {
        let currentTheme: Models.AppearanceMode
        let customColor: Models.CustomColor?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Label("テーマプレビュー", systemImage: "eye")
                    .font(.headline)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(previewBackgroundColor)
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            HStack {
                                Text("AsaClipBoard")
                                    .font(.headline)
                                    .foregroundColor(previewTextColor)
                                
                                Spacer()
                                
                                Circle()
                                    .fill(previewAccentColor)
                                    .frame(width: 12, height: 12)
                            }
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(previewSurfaceColor)
                                    .frame(width: 40, height: 24)
                                
                                VStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(previewTextColor.opacity(0.8))
                                        .frame(height: 8)
                                    Rectangle()
                                        .fill(previewTextColor.opacity(0.5))
                                        .frame(width: 60, height: 6)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text("現在のテーマ: \(currentTheme.displayName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        private var previewBackgroundColor: Color {
            if let customColor = customColor {
                return customColor.background
            }
            
            switch currentTheme {
            case .light:
                return .white
            case .dark:
                return Color(NSColor.windowBackgroundColor)
            case .system:
                return Color(NSColor.windowBackgroundColor)
            }
        }
        
        private var previewTextColor: Color {
            if let customColor = customColor {
                return customColor.primary
            }
            
            switch currentTheme {
            case .light:
                return .black
            case .dark:
                return .white
            case .system:
                return Color(NSColor.labelColor)
            }
        }
        
        private var previewAccentColor: Color {
            if let customColor = customColor {
                return customColor.accent
            }
            return .blue
        }
        
        private var previewSurfaceColor: Color {
            if let customColor = customColor {
                return customColor.surface
            }
            
            switch currentTheme {
            case .light:
                return Color.gray.opacity(0.1)
            case .dark:
                return Color.white.opacity(0.1)
            case .system:
                return Color(NSColor.controlBackgroundColor)
            }
        }
    }
}