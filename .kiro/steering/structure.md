# Project Structure - AsaClipBoard

## Root Directory Organization

```
AsaClipBoard/
├── .gitignore              # Xcode and Swift ignore patterns
├── .kiro/                  # Kiro spec-driven development files
│   ├── steering/           # Project guidance documents
│   └── specs/              # Feature specifications
├── .claude/                # Claude Code commands and hooks
├── CLAUDE.md               # Claude Code project instructions
├── LICENSE                 # MIT License
├── README.md               # Project documentation
├── AsaClipBoard.xcodeproj  # Xcode project file (to be created)
├── AsaClipBoard/           # iOS app target
├── AsaClipBoard-macOS/     # macOS app target
├── AsaClipBoardCore/       # Shared business logic framework
├── AsaClipBoardTests/      # Unit tests
└── AsaClipBoardUITests/    # UI and integration tests
```

## Proposed Directory Structure

### iOS App Target (`AsaClipBoard/`)

```
AsaClipBoard/
├── App/
│   ├── AppDelegate.swift           # iOS app lifecycle
│   ├── SceneDelegate.swift         # Scene management
│   └── Info.plist                  # iOS app configuration
├── Views/
│   ├── ClipboardHistory/           # Main clipboard history interface
│   ├── Settings/                   # App settings and preferences
│   ├── Common/                     # Reusable UI components
│   └── Extensions/                 # Share extension and widgets
├── Controllers/
│   ├── ClipboardViewController.swift
│   ├── SettingsViewController.swift
│   └── BaseViewController.swift
├── Models/
│   ├── ClipboardItem.swift         # Core data models
│   └── UserPreferences.swift       # Settings model
└── Resources/
    ├── Assets.xcassets             # Images and colors
    ├── Base.lproj/                 # Localization
    └── LaunchScreen.storyboard     # Launch screen
```

### macOS App Target (`AsaClipBoard-macOS/`)

```
AsaClipBoard-macOS/
├── App/
│   ├── AppDelegate.swift           # macOS app lifecycle
│   ├── MainMenu.xib                # Main menu configuration
│   └── Info.plist                  # macOS app configuration
├── Views/
│   ├── MainWindow/                 # Primary window interface
│   ├── MenuBar/                    # Menu bar integration
│   ├── Preferences/                # Preferences window
│   └── Common/                     # Shared UI components
├── Controllers/
│   ├── MainWindowController.swift
│   ├── MenuBarController.swift
│   └── PreferencesController.swift
├── Services/
│   ├── GlobalHotKeyService.swift   # System-wide shortcuts
│   └── MenuBarService.swift        # Menu bar management
└── Resources/
    ├── Assets.xcassets             # macOS-specific assets
    └── Base.lproj/                 # Localization
```

### Shared Core Framework (`AsaClipBoardCore/`)

```
AsaClipBoardCore/
├── Data/
│   ├── CoreData/
│   │   ├── ClipboardModel.xcdatamodeld  # Core Data model
│   │   └── PersistenceController.swift  # Core Data stack
│   ├── CloudKit/
│   │   ├── CloudKitManager.swift        # CloudKit integration
│   │   └── SyncService.swift            # Cross-device sync
│   └── Storage/
│       ├── LocalStorage.swift           # Local data access
│       └── UserDefaults+Extensions.swift
├── Services/
│   ├── ClipboardMonitor.swift           # Clipboard monitoring
│   ├── ContentProcessor.swift           # Content type handling
│   ├── HistoryManager.swift             # Clipboard history logic
│   └── SecurityManager.swift            # Sensitive content detection
├── Models/
│   ├── ClipboardItem.swift              # Core data structures
│   ├── ContentType.swift                # Content type definitions
│   └── SyncState.swift                  # Synchronization state
├── Extensions/
│   ├── String+ClipboardUtils.swift      # String utilities
│   ├── Data+ContentType.swift           # Data type detection
│   └── Date+Formatting.swift            # Date utilities
└── Protocols/
    ├── ClipboardServiceProtocol.swift   # Service abstractions
    └── StorageProtocol.swift             # Storage abstractions
```

## Code Organization Patterns

### Architectural Pattern
- **MVVM (Model-View-ViewModel)**: Primary architectural pattern for UI layers
- **Service Layer**: Business logic separated into dedicated service classes
- **Repository Pattern**: Data access abstraction through repository interfaces
- **Dependency Injection**: Protocol-based dependency injection for testability

### Platform-Specific Organization
- **Shared Core**: Maximum code reuse through shared framework
- **Platform UI**: Separate UI implementations respecting platform conventions
- **Feature Modules**: Grouped functionality by feature rather than layer
- **Protocol-Oriented**: Heavy use of Swift protocols for abstraction

### Import Organization
```swift
// System frameworks first
import Foundation
import UIKit  // or AppKit for macOS
import CoreData
import CloudKit

// Third-party dependencies
import SomeThirdPartyFramework

// Internal modules
import AsaClipBoardCore

// Local imports (same module)
import "LocalFile.swift"
```

## File Naming Conventions

### Swift Files
- **ViewControllers**: `FeatureViewController.swift`
- **Views**: `FeatureView.swift` or `FeatureTableViewCell.swift`
- **Models**: `EntityName.swift` (singular, descriptive)
- **Services**: `FeatureService.swift` or `FeatureManager.swift`
- **Extensions**: `TypeName+FeatureName.swift`
- **Protocols**: `FeatureProtocol.swift` or `FeatureDelegate.swift`

### Resource Files
- **Storyboards**: `Feature.storyboard`
- **XIB Files**: `FeatureView.xib`
- **Asset Catalogs**: `Assets.xcassets` (default) or `FeatureAssets.xcassets`
- **Localization**: `Localizable.strings`, `InfoPlist.strings`

### Test Files
- **Unit Tests**: `FeatureTests.swift`
- **UI Tests**: `FeatureUITests.swift`
- **Mock Objects**: `MockFeatureService.swift`

## Key Architectural Principles

### Separation of Concerns
- **UI Layer**: Only UI logic and user interaction
- **Business Layer**: Core application logic and rules
- **Data Layer**: Storage, persistence, and external data access
- **Service Layer**: Cross-cutting concerns and utilities

### Platform Integration
- **Native UI**: Use platform-native UI components and patterns
- **System Integration**: Leverage platform-specific APIs and services
- **Performance**: Optimize for each platform's performance characteristics
- **Accessibility**: Built-in support for platform accessibility features

### Testability
- **Protocol-Based Design**: All major components behind protocols
- **Dependency Injection**: Externally provided dependencies
- **Pure Functions**: Stateless functions where possible
- **Isolated Side Effects**: Clear separation of side effects

### Maintainability
- **Clear Module Boundaries**: Well-defined responsibilities for each module
- **Consistent Naming**: Predictable naming conventions throughout
- **Documentation**: Code-level documentation for complex logic
- **Error Handling**: Comprehensive error handling and logging

### Security and Privacy
- **Data Minimization**: Only collect and store necessary data
- **Local-First**: Default to local storage and processing
- **Secure Defaults**: Secure configuration out of the box
- **User Control**: User visibility and control over data handling