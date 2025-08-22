# Project Structure

## Root Directory
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

## Code Organization Patterns

### Architectural Pattern
- **MVVM (Model-View-ViewModel)**: Primary pattern for UI layers
- **Service Layer**: Business logic in dedicated service classes
- **Repository Pattern**: Data access abstraction
- **Protocol-Oriented Design**: Heavy use of Swift protocols for abstraction

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