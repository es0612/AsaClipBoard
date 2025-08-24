# Technology Stack - AsaClipBoard

## Architecture
AsaClipBoard follows a native macOS architecture designed for optimal performance and platform integration:

- **Native macOS Development**: Built specifically for macOS using SwiftUI and MenuBarExtra
- **Modular SPM Packages**: Business logic organized into Swift Package Manager packages
- **MVVM + Service Layer**: Clean architecture with separation of concerns
- **Local-First Data**: Primary data storage on device with security-first approach

## Primary Technologies
- **Language**: Swift 5.9+
- **Platform**: macOS 14.0+
- **UI Framework**: SwiftUI with MenuBarExtra integration
- **Architecture**: MVVM + Service Layer with SPM packages
- **Project Generation**: XcodeGen with YAML configuration

## Package Architecture
The project uses Swift Package Manager (SPM) with a modular package structure:

### ClipboardSecurity Package
- **Purpose**: Security and privacy features
- **Dependencies**: KeychainSwift (external)
- **Components**:
  - SecurityManager: Sensitive content detection
  - KeychainManager: Secure data storage
  - EncryptionManager: Data encryption/decryption with CryptoKit

### ClipboardCore Package  
- **Purpose**: Business logic and data management
- **Dependencies**: ClipboardSecurity
- **Components**: Core clipboard functionality and data models

### ClipboardUI Package
- **Purpose**: User interface components
- **Dependencies**: ClipboardCore, ClipboardSecurity
- **Components**: SwiftUI views and reusable UI components

## Development Environment

### Required Tools
- **Xcode**: 14.0+ (latest stable recommended)
- **XcodeGen**: Project file generation from YAML configuration
- **Swift Package Manager**: Primary dependency management
- **Testing**: SwiftTesting framework for modern test-driven development

## External Dependencies
- **KeychainSwift**: Secure keychain access for sensitive data storage

## Common Development Commands

### Project Generation and Building
```bash
# Generate Xcode project from YAML configuration
xcodegen generate

# Open project in Xcode
open AsaClipBoard.xcodeproj

# Build for macOS
xcodebuild -project AsaClipBoard.xcodeproj -scheme AsaClipBoard
```

### Testing
```bash
# Run macOS tests
xcodebuild test -project AsaClipBoard.xcodeproj -scheme AsaClipBoard

# Test individual packages
# In ClipboardSecurity/
swift test

# In ClipboardCore/
swift test

# In ClipboardUI/
swift test
```

### Package Management
```bash
# Resolve dependencies for main project
xcodebuild -resolvePackageDependencies

# Resolve dependencies for individual packages
swift package resolve
```

## Environment Configuration

### Build Configurations
- **Debug**: Development builds with debugging symbols and verbose logging
- **Release**: Production builds with optimizations and minimal logging

### Target Platform
- **macOS**: Desktop application with MenuBarExtra integration (macOS 14.0+)
- **LSUIElement**: Application runs as background utility without dock icon

### Key Configuration Variables
- `CLIPBOARD_HISTORY_LIMIT`: Maximum number of clipboard items to store
- `DEBUG_LOGGING`: Control logging verbosity for development
- `BACKGROUND_MONITORING`: Enable background clipboard monitoring

## Platform Integration

### macOS-Specific Technologies
- **MenuBarExtra**: SwiftUI-based menu bar integration for modern macOS development
- **NSPasteboard**: Native clipboard monitoring and management
- **Global Hotkeys**: System-wide keyboard shortcuts for clipboard access
- **Background Operation**: LSUIElement configuration for background-only operation

## Security Features
- **CryptoKit**: Built-in encryption using AES-GCM
- **Keychain Services**: Secure storage for sensitive configuration
- **Local-First Storage**: Default local storage without cloud dependency
- **Sensitive Content Detection**: Automatic detection of passwords, API keys, credit cards