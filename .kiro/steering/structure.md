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
├── project.yml             # XcodeGen configuration
├── AsaClipBoard.xcodeproj  # Generated Xcode project
├── AsaClipBoard/           # Main macOS app target
├── ClipboardSecurity/      # Security SPM package
├── ClipboardCore/          # Core logic SPM package
└── ClipboardUI/            # UI components SPM package
```

## SPM Package Structure
Each Swift package follows standard SPM structure:
```
PackageName/
├── Package.swift           # Package configuration
├── Package.resolved        # Resolved dependencies
├── Sources/
│   └── PackageName/        # Source code
└── Tests/
    └── PackageNameTests/   # Test files
```

### Main App Target (`AsaClipBoard/`)

```
AsaClipBoard/
├── AsaClipBoardApp.swift           # SwiftUI app entry point
├── ContentView.swift               # Main content view
├── SettingsView.swift             # Settings interface
└── Info.plist                     # App configuration (LSUIElement, etc.)
```

### ClipboardSecurity Package

```
ClipboardSecurity/
├── Package.swift                   # Package configuration with KeychainSwift dependency
├── Sources/ClipboardSecurity/
│   ├── SecurityManager.swift       # Sensitive content detection
│   ├── KeychainManager.swift       # Secure keychain operations
│   ├── EncryptionManager.swift     # CryptoKit-based encryption
│   └── ClipboardSecurity.swift     # Package entry point
└── Tests/ClipboardSecurityTests/
    ├── SecurityManagerTests.swift
    ├── KeychainManagerTests.swift
    ├── EncryptionManagerTests.swift
    ├── SecurityIntegrationTests.swift
    └── TestDataProvider.swift
```

### ClipboardCore Package

```
ClipboardCore/
├── Package.swift                           # Package configuration with ClipboardSecurity dependency
├── Package.resolved                        # Resolved dependencies
├── Sources/ClipboardCore/
│   ├── Models/
│   │   ├── ClipboardItemModel.swift        # Core data structures for clipboard items
│   │   ├── ClipboardContentType.swift      # Content type definitions and enums
│   │   ├── CategoryModel.swift             # Category organization model
│   │   ├── SmartAction.swift               # Smart action definitions
│   │   └── SmartActionModel.swift          # Smart action data model
│   ├── Services/
│   │   ├── ClipboardHistoryManager.swift   # Main clipboard data management
│   │   ├── ClipboardMonitorService.swift   # NSPasteboard monitoring service
│   │   ├── SearchManager.swift             # Advanced search and indexing
│   │   ├── SmartContentRecognizer.swift    # Content pattern recognition
│   │   ├── CloudKitSyncManager.swift       # CloudKit synchronization
│   │   ├── HotkeyManager.swift             # Global hotkey management
│   │   ├── ClipboardError.swift            # Error definitions and types
│   │   ├── ErrorLogger.swift               # Comprehensive error logging
│   │   └── ErrorRecovery.swift             # Error recovery mechanisms
│   └── ClipboardCore.swift                 # Package entry point
└── Tests/ClipboardCoreTests/
    ├── ClipboardItemModelTests.swift
    ├── ClipboardContentTypeTests.swift
    ├── CategoryModelTests.swift
    ├── SmartActionModelTests.swift
    ├── ClipboardHistoryManagerTests.swift
    ├── ClipboardMonitorServiceTests.swift
    ├── SearchManagerTests.swift
    ├── SearchPerformanceTests.swift
    ├── SmartContentRecognizerTests.swift
    ├── CloudKitSyncManagerTests.swift
    ├── HotkeyManagerTests.swift
    ├── ErrorHandlingTests.swift
    ├── MockPasteboard.swift                # Test utilities and mocks
    └── ClipboardCoreTests.swift
```

### ClipboardUI Package

```
ClipboardUI/
├── Package.swift                             # Package configuration with Core and Security dependencies
├── Package.resolved                          # Resolved dependencies
├── Sources/ClipboardUI/
│   ├── Views/
│   │   ├── ClipboardHistoryView.swift        # Main clipboard history interface
│   │   ├── ClipboardItemRow.swift            # Individual clipboard item view
│   │   ├── SettingsView.swift                # Main settings interface
│   │   ├── HotkeySettingsView.swift          # Hotkey configuration view
│   │   └── AppearanceSettingsView.swift      # Theme and appearance settings
│   ├── Components/
│   │   ├── SearchBar.swift                   # Search input component
│   │   ├── FilterBar.swift                   # Content filtering controls
│   │   ├── ContentTypeIcon.swift             # Content type icon component
│   │   ├── SmartActionsView.swift            # Smart action buttons
│   │   ├── SwipeActionsView.swift            # Swipe gesture actions
│   │   └── ClipboardItemContextMenu.swift    # Right-click context menu
│   ├── Controllers/
│   │   ├── MenuBarExtraManager.swift         # Menu bar integration controller
│   │   ├── ClipboardWindowController.swift   # Window management controller
│   │   ├── HotkeyEventProcessor.swift        # Hotkey event handling
│   │   ├── NotificationManager.swift         # System notifications controller
│   │   └── AccessibilityManager.swift        # Accessibility features controller
│   ├── Models/
│   │   ├── SettingsManager.swift             # User settings management
│   │   ├── AppearanceManager.swift           # Theme and appearance management
│   │   └── ContentFilter.swift               # Content filtering model
│   └── ClipboardUI.swift                     # Package entry point
└── Tests/ClipboardUITests/
    ├── ClipboardHistoryViewTests.swift
    ├── ClipboardItemRowTests.swift
    ├── SettingsViewTests.swift
    ├── SearchBarTests.swift
    ├── FilterBarTests.swift
    ├── ContentTypeIconTests.swift
    ├── SmartActionsViewTests.swift
    ├── SwipeActionsTests.swift
    ├── ClipboardItemContextMenuTests.swift
    ├── MenuBarExtraManagerTests.swift
    ├── ClipboardWindowControllerTests.swift
    ├── HotkeyEventProcessorTests.swift
    ├── NotificationManagerTests.swift
    ├── AccessibilityManagerTests.swift
    └── ClipboardUITests.swift
```

## Code Organization Patterns

### Architectural Pattern
- **MVVM (Model-View-ViewModel)**: Primary pattern for UI layers
- **Service Layer**: Business logic in dedicated service classes
- **Repository Pattern**: Data access abstraction
- **Protocol-Oriented Design**: Heavy use of Swift protocols for abstraction

### Package Organization
- **Layered Architecture**: Security → Core → UI dependency chain
- **Single Responsibility**: Each package has a focused purpose
- **Modular Design**: Independent packages with clear boundaries
- **Test-Driven Development**: Comprehensive test coverage for all packages

### Import Organization
```swift
// System frameworks first
import Foundation
import SwiftUI
import CryptoKit

// Third-party dependencies
import KeychainSwift

// Internal modules
import ClipboardCore
import ClipboardSecurity

// Local imports (same module)
// No explicit imports needed for same module
```

## File Naming Conventions
- **Managers/Services**: `FeatureManager.swift`, `FeatureService.swift`
- **Models**: `EntityName.swift` (singular, descriptive)
- **Views**: `FeatureView.swift`
- **Extensions**: `TypeName+FeatureName.swift`
- **Protocols**: `FeatureProtocol.swift`
- **Tests**: `FeatureTests.swift`, `FeatureManagerTests.swift`

## Key Architectural Principles

### Separation of Concerns
- **UI Layer**: SwiftUI views, controllers, and user interaction (ClipboardUI)
  - Views: User interface components and screens
  - Controllers: System integration and event handling (MenuBar, Hotkeys, Notifications, Accessibility)
  - Models: UI state management and user preferences
- **Business Layer**: Core application logic and rules (ClipboardCore)
  - Services: Business logic services (History, Monitor, Search, Sync, Recognition)
  - Models: Domain data models and business entities
- **Security Layer**: Encryption, keychain, sensitive data handling (ClipboardSecurity)
  - Security: Content detection, encryption, keychain management
- **App Layer**: SwiftUI app entry point and MenuBarExtra integration
  - Main app target with system-level integration

### Platform Integration
- **Native macOS**: SwiftUI with MenuBarExtra for modern macOS development
- **System Integration**: NSPasteboard monitoring, Carbon HotKey API, and background operation
- **CloudKit Integration**: Device synchronization with conflict resolution and offline support
- **Notification Integration**: UserNotifications framework for system-level notifications
- **Accessibility Integration**: VoiceOver support, keyboard navigation, and accessibility compliance
- **Window Management**: Custom NSWindow integration for floating interface
- **Performance**: Memory-optimized clipboard monitoring with efficient search indexing
- **Security Integration**: Keychain Services and CryptoKit for data protection

### Testability
- **Protocol-Based Design**: All major components behind protocols for easy mocking and testing
- **Package Isolation**: Each package independently testable with focused test suites
- **Comprehensive Testing**: Unit tests for all business logic with SwiftTesting framework
- **Test-Driven Development**: TDD methodology with tests written before implementation
- **Performance Testing**: Dedicated performance tests for search and memory optimization
- **Integration Testing**: Cross-package integration tests for complete workflows
- **Mock Infrastructure**: Comprehensive mocking utilities (MockPasteboard, TestDataProvider)
- **Error Testing**: Dedicated tests for error handling and recovery mechanisms

### Security and Privacy
- **Security-First**: Dedicated ClipboardSecurity package for all sensitive operations
- **Local-First**: Default to local storage and processing with optional CloudKit sync
- **Encryption by Default**: CryptoKit-based AES-GCM encryption for sensitive data
- **Keychain Integration**: Secure storage using native macOS keychain for encryption keys
- **Sensitive Content Detection**: Automatic detection of passwords, API keys, credit cards
- **Data Classification**: Automatic categorization with security warnings for sensitive content
- **Audit Logging**: Security event logging for sensitive data interactions
- **Memory Protection**: Secure memory handling for clipboard data
- **Recovery Mechanisms**: Robust error recovery with data integrity validation