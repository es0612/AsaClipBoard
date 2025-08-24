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
├── Package.swift                   # Package configuration with ClipboardSecurity dependency
├── Sources/ClipboardCore/
│   ├── Models/
│   │   ├── ClipboardItemModel.swift    # Core data structures
│   │   └── ClipboardContentType.swift  # Content type definitions
│   └── ClipboardCore.swift         # Package entry point
└── Tests/ClipboardCoreTests/
    ├── ClipboardItemModelTests.swift
    ├── ClipboardContentTypeTests.swift
    └── ClipboardCoreTests.swift
```

### ClipboardUI Package

```
ClipboardUI/
├── Package.swift                   # Package configuration with Core and Security dependencies
├── Sources/ClipboardUI/
│   ├── Views/
│   │   └── ClipboardItemRow.swift  # Individual clipboard item view
│   ├── Components/
│   │   └── ContentTypeIcon.swift   # Content type icon component
│   └── ClipboardUI.swift           # Package entry point
└── Tests/ClipboardUITests/
    ├── ClipboardItemRowTests.swift
    ├── ContentTypeIconTests.swift
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
- **UI Layer**: SwiftUI views and user interaction (ClipboardUI)
- **Business Layer**: Core application logic and rules (ClipboardCore)  
- **Security Layer**: Encryption, keychain, sensitive data handling (ClipboardSecurity)
- **App Layer**: SwiftUI app entry point and MenuBarExtra integration

### Platform Integration
- **Native macOS**: SwiftUI with MenuBarExtra for modern macOS development
- **System Integration**: NSPasteboard monitoring and background operation
- **Performance**: Optimized for macOS clipboard monitoring efficiency
- **Accessibility**: Built-in SwiftUI accessibility support

### Testability
- **Protocol-Based Design**: All major components behind protocols
- **Package Isolation**: Each package independently testable
- **Comprehensive Testing**: Unit tests for all business logic
- **Test-Driven Development**: Tests written alongside implementation

### Security and Privacy
- **Security-First**: Dedicated ClipboardSecurity package for all sensitive operations
- **Local-First**: Default to local storage and processing
- **Encryption by Default**: CryptoKit-based encryption for sensitive data
- **Keychain Integration**: Secure storage using native macOS keychain