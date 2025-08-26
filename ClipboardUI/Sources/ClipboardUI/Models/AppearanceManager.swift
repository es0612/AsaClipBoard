import SwiftUI
import Foundation
import Observation
import AppKit

extension Models {
    public typealias AppearanceManager = ClipboardUIAppearanceManager
    public typealias CustomColor = ClipboardUICustomColor
}

// MARK: - Appearance Management
@Observable
public class ClipboardUIAppearanceManager {
    public var currentTheme: ClipboardUIAppearanceMode = .system {
        didSet {
            onThemeChanged?()
            saveSettings()
        }
    }
    
    public var customColors: ClipboardUICustomColor? {
        didSet {
            onThemeChanged?()
            saveSettings()
        }
    }
    
    public var onThemeChanged: (() -> Void)?
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "appearance_theme"
    private let customColorsKey = "custom_colors"
    
    public init() {
        loadSettings()
    }
    
    public func setTheme(_ theme: ClipboardUIAppearanceMode) {
        currentTheme = theme
    }
    
    public func setCustomColors(_ colors: ClipboardUICustomColor) {
        customColors = colors
    }
    
    public func detectSystemAppearance() -> ClipboardUIAppearanceMode {
        guard let appearance = NSApp?.effectiveAppearance else {
            // Test environment fallback - return system default
            return .system
        }
        if appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua {
            return .dark
        } else {
            return .light
        }
    }
    
    public func saveSettings() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
        
        if let customColors = customColors {
            let hexValues = customColors.toHexValues()
            if let data = try? JSONEncoder().encode(hexValues) {
                userDefaults.set(data, forKey: customColorsKey)
            }
        }
        
        // Synchronize to ensure immediate persistence (important for tests)
        userDefaults.synchronize()
    }
    
    private func loadSettings() {
        if let themeString = userDefaults.string(forKey: themeKey),
           let theme = ClipboardUIAppearanceMode(rawValue: themeString) {
            currentTheme = theme
        }
        
        if let data = userDefaults.data(forKey: customColorsKey),
           let hexValues = try? JSONDecoder().decode([String: String].self, from: data) {
            customColors = ClipboardUICustomColor.fromHexValues(hexValues)
        }
    }
}
    
// MARK: - Custom Color Management
public struct ClipboardUICustomColor: Equatable {
    public let primary: Color
    public let secondary: Color
    public let accent: Color
    public let background: Color
    public let surface: Color
    
    public init(primary: Color, secondary: Color, accent: Color, background: Color, surface: Color) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.surface = surface
    }
    
    public static let defaultLight = ClipboardUICustomColor(
        primary: .blue,
        secondary: .gray,
        accent: .blue,
        background: .white,
        surface: Color.gray.opacity(0.1)
    )
    
    public static let defaultDark = ClipboardUICustomColor(
        primary: .blue,
        secondary: .gray,
        accent: .blue,
        background: .black,
        surface: Color.white.opacity(0.1)
    )
    
    public func toHexValues() -> [String: String] {
        return [
            "primary": primary.toHex(),
            "secondary": secondary.toHex(),
            "accent": accent.toHex(),
            "background": background.toHex(),
            "surface": surface.toHex()
        ]
    }
    
    public static func fromHexValues(_ hexValues: [String: String]) -> ClipboardUICustomColor? {
        guard let primaryHex = hexValues["primary"],
              let secondaryHex = hexValues["secondary"],
              let accentHex = hexValues["accent"],
              let backgroundHex = hexValues["background"],
              let surfaceHex = hexValues["surface"] else {
            return nil
        }
        
        return ClipboardUICustomColor(
            primary: Color.fromHex(primaryHex) ?? .blue,
            secondary: Color.fromHex(secondaryHex) ?? .gray,
            accent: Color.fromHex(accentHex) ?? .blue,
            background: Color.fromHex(backgroundHex) ?? .white,
            surface: Color.fromHex(surfaceHex) ?? Color.gray.opacity(0.1)
        )
    }
}

// MARK: - Color Extensions
extension Color {
    func toHex() -> String {
        let uiColor = NSColor(self)
        guard let components = uiColor.cgColor.components else { return "#000000" }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    static func fromHex(_ hex: String) -> Color? {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        guard cleanHex.count == 6,
              let intValue = Int(cleanHex, radix: 16) else {
            return nil
        }
        
        let r = Double((intValue >> 16) & 0xFF) / 255.0
        let g = Double((intValue >> 8) & 0xFF) / 255.0
        let b = Double(intValue & 0xFF) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
}