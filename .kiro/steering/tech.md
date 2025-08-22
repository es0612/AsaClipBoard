# Technology Stack - AsaClipBoard

## Architecture
AsaClipBoard follows a native Apple platform architecture designed for optimal performance and platform integration:

- **Native iOS/macOS Development**: Built specifically for Apple platforms using UIKit (iOS) and AppKit (macOS)
- **Shared Business Logic**: Common core functionality shared between iOS and macOS targets
- **Platform-Specific UI**: Tailored user interfaces that respect each platform's design patterns
- **Local-First Data**: Primary data storage on device with optional cloud sync capabilities

## Platform Technologies

### iOS Development
- **Language**: Swift 5.x
- **Minimum iOS Version**: iOS 15.0+
- **UI Framework**: UIKit with programmatic layouts
- **Background Processing**: Background App Refresh for clipboard monitoring
- **iCloud Integration**: CloudKit for optional cross-device synchronization

### macOS Development  
- **Language**: Swift 5.x
- **Minimum macOS Version**: macOS 12.0+
- **UI Framework**: AppKit with Auto Layout
- **System Integration**: NSPasteboard monitoring and system menu integration
- **Background Services**: Launch agents for persistent clipboard monitoring

### Shared Components
- **Core Data**: Local storage and data persistence
- **CloudKit**: Cross-platform synchronization (optional)
- **Combine**: Reactive programming for UI updates and data flow
- **Foundation**: Core functionality and system APIs

## Development Environment

### Required Tools
- **Xcode**: 14.0+ (latest stable recommended)
- **Swift**: 5.7+ (bundled with Xcode)
- **iOS Simulator**: For iOS development and testing
- **macOS**: Development machine must run macOS for Xcode compatibility

### Package Management
- **Swift Package Manager (SPM)**: Primary dependency management
- **CocoaPods**: Legacy support if needed for specific dependencies
- **Carthage**: Alternative binary framework management

### Testing Framework
- **XCTest**: Unit and UI testing framework
- **XCUITest**: Integration and end-to-end testing
- **Quick/Nimble**: BDD-style testing (if adopted)

## Common Development Commands

### Building and Running
```bash
# Open project in Xcode
open AsaClipBoard.xcodeproj

# Build for iOS
xcodebuild -project AsaClipBoard.xcodeproj -scheme AsaClipBoard-iOS -destination 'platform=iOS Simulator,name=iPhone 14'

# Build for macOS  
xcodebuild -project AsaClipBoard.xcodeproj -scheme AsaClipBoard-macOS
```

### Testing
```bash
# Run iOS tests
xcodebuild test -project AsaClipBoard.xcodeproj -scheme AsaClipBoard-iOS -destination 'platform=iOS Simulator,name=iPhone 14'

# Run macOS tests
xcodebuild test -project AsaClipBoard.xcodeproj -scheme AsaClipBoard-macOS
```

### Package Management
```bash
# Resolve Swift Package Manager dependencies
xcodebuild -resolvePackageDependencies

# Update Swift packages
# (Done through Xcode: File > Add Package Dependencies)
```

## Environment Configuration

### Build Configurations
- **Debug**: Development builds with debugging symbols and verbose logging
- **Release**: Production builds with optimizations and minimal logging
- **Testing**: Specialized configuration for automated testing

### Target Platforms
- **iOS**: iPhone and iPad support with adaptive UI
- **macOS**: Desktop application with menu bar integration
- **Shared Framework**: Common business logic and data models

### Key Configuration Variables
- `CLIPBOARD_HISTORY_LIMIT`: Maximum number of clipboard items to store
- `SYNC_ENABLED`: Enable/disable CloudKit synchronization
- `DEBUG_LOGGING`: Control logging verbosity for development
- `BACKGROUND_MONITORING`: Enable background clipboard monitoring

## Platform Integration

### iOS-Specific Technologies
- **App Extensions**: Share Extension for capturing content from other apps
- **Shortcuts Integration**: Siri Shortcuts for voice-activated clipboard access
- **Widget Extensions**: Home/Lock screen widgets for quick clipboard access
- **Universal Clipboard**: Integration with iOS Universal Clipboard feature

### macOS-Specific Technologies
- **Menu Bar Integration**: System menu bar icon and quick access menu
- **Global Hotkeys**: System-wide keyboard shortcuts for clipboard access
- **Dock Integration**: Dock menu integration for power user workflows
- **System Services**: Integration with macOS Services menu

## Security and Privacy

### Data Protection
- **App Sandbox**: Strict sandboxing for both iOS and macOS
- **Keychain Services**: Secure storage for sensitive configuration
- **Data Encryption**: Core Data encryption for local storage
- **Network Security**: TLS encryption for any network communication

### Privacy Features
- **Local-First Storage**: Default local storage without cloud dependency
- **User-Controlled Sync**: Optional iCloud sync with explicit user consent
- **Sensitive Content Detection**: Automatic detection and handling of passwords/keys
- **Data Expiration**: Configurable automatic cleanup of old clipboard items