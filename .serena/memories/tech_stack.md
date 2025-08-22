# Technology Stack

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
- **Components**: Core clipboard functionality (to be developed)

### ClipboardUI Package
- **Purpose**: User interface components
- **Dependencies**: ClipboardCore, ClipboardSecurity
- **Components**: SwiftUI views and components (to be developed)

## Development Tools
- **Xcode**: 14.0+ (latest stable recommended)
- **XcodeGen**: Project file generation from YAML configuration
- **Swift Package Manager**: Primary dependency management
- **Testing**: SwiftTesting framework for modern test-driven development

## External Dependencies
- **KeychainSwift**: Secure keychain access for sensitive data storage

## Security Features
- **CryptoKit**: Built-in encryption using AES-GCM
- **Keychain Services**: Secure storage for sensitive configuration
- **Local-First Storage**: Default local storage without cloud dependency
- **Sensitive Content Detection**: Automatic detection of passwords, API keys, credit cards