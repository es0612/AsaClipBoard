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
- **Components**:
  - ClipboardHistoryManager: Clipboard data management with memory optimization
  - ClipboardMonitorService: NSPasteboard monitoring and content detection
  - SearchManager: Advanced search with indexing and fuzzy matching
  - SmartContentRecognizer: Pattern recognition for URLs, emails, phone numbers, colors
  - CloudKitSyncManager: Device synchronization with conflict resolution
  - HotkeyManager: Global hotkey registration using Carbon API
  - ErrorLogger & ErrorRecovery: Comprehensive error handling and recovery
  - Data Models: ClipboardItemModel, CategoryModel, SmartActionModel

### ClipboardUI Package
- **Purpose**: User interface components
- **Dependencies**: ClipboardCore, ClipboardSecurity
- **Components**:
  - Views: ClipboardHistoryView, ClipboardItemRow, SettingsView, HotkeySettingsView, AppearanceSettingsView
  - Components: SearchBar, FilterBar, ContentTypeIcon, SmartActionsView, SwipeActionsView, ClipboardItemContextMenu
  - Controllers: MenuBarExtraManager, ClipboardWindowController, HotkeyEventProcessor, NotificationManager, AccessibilityManager
  - Models: SettingsManager, AppearanceManager, ContentFilter

## Development Environment

### Required Tools
- **Xcode**: 15.0+ (latest stable recommended for SwiftTesting support)
- **XcodeGen**: Project file generation from YAML configuration
- **Swift Package Manager**: Primary dependency management
- **Testing**: SwiftTesting framework for modern test-driven development with TDD methodology

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
- `CLIPBOARD_HISTORY_LIMIT`: Maximum number of clipboard items to store (default: 1000)
- `DEBUG_LOGGING`: Control logging verbosity for development
- `BACKGROUND_MONITORING`: Enable background clipboard monitoring
- `CLOUDKIT_SYNC_ENABLED`: Control CloudKit synchronization feature
- `HOTKEY_ENABLED`: Enable global hotkey functionality
- `SMART_ACTIONS_ENABLED`: Enable smart content recognition and actions
- `NOTIFICATIONS_ENABLED`: Control system notifications
- `ACCESSIBILITY_MODE`: Enhanced accessibility features
- `MEMORY_LIMIT_MB`: Memory usage limit for clipboard storage

## Platform Integration

### macOS-Specific Technologies
- **MenuBarExtra**: SwiftUI-based menu bar integration with modern macOS development
- **NSPasteboard**: Native clipboard monitoring and management with real-time content detection
- **Carbon HotKey API**: System-wide keyboard shortcuts for global clipboard access
- **CloudKit**: Device-to-device synchronization with conflict resolution and offline support
- **UserNotifications**: System notifications for sync events and important interactions
- **Accessibility**: VoiceOver support and keyboard navigation compliance
- **NSWindow**: Custom window management for floating clipboard interface
- **Background Operation**: LSUIElement configuration for background-only operation with memory optimization

## Security Features
- **CryptoKit**: Built-in encryption using AES-GCM for sensitive data protection
- **Keychain Services**: Secure storage for encryption keys and sensitive configuration
- **Local-First Storage**: Default local storage without cloud dependency, with optional CloudKit sync
- **Sensitive Content Detection**: Automatic detection of passwords, API keys, credit cards, and other sensitive patterns
- **Data Classification**: Automatic categorization of sensitive content with security warnings
- **Secure Memory Handling**: Memory protection for sensitive clipboard data
- **Audit Logging**: Security event logging for sensitive data interactions
- **Recovery Mechanisms**: Robust error recovery and data integrity validation