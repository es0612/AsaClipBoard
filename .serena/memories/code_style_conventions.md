# Code Style and Conventions

## Swift Code Style

### General Principles
- Follow Swift API Design Guidelines
- Prefer clarity over brevity
- Use meaningful, descriptive names
- Maintain consistency across the codebase

### Naming Conventions
- **Types**: PascalCase (`SecurityManager`, `ClipboardItem`)
- **Functions/Variables**: camelCase (`detectSensitiveContent`, `isPrivateModeEnabled`)
- **Constants**: camelCase (`maxHistoryLimit`, `defaultTimeout`)
- **Enums**: PascalCase with lowercase cases (`ContentType.text`, `EncryptionError.decryptionFailed`)
- **Protocols**: PascalCase, often ending with Protocol (`ClipboardServiceProtocol`)

### Code Organization
```swift
// File structure order:
import Foundation
import SwiftUI
import ClipboardCore

/// Documentation comment for the class
public class SecurityManager {
    // MARK: - Properties
    private var _isPrivateModeEnabled: Bool = false
    
    // MARK: - Initialization
    public init() {}
    
    // MARK: - Public Methods
    public func detectSensitiveContent(_ text: String) -> Bool {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func detectPassword(_ text: String) -> Bool {
        // Implementation
    }
}
```

### Documentation
- Use triple-slash comments (`///`) for public APIs
- Include parameter descriptions for complex methods
- Document return values and thrown errors
- Use `// MARK: -` to organize code sections

### Error Handling
- Use Swift's error handling with `throws` and `try`
- Define custom error enums that conform to `LocalizedError`
- Provide meaningful error messages
- Example:
```swift
public enum KeychainError: LocalizedError {
    case storageError(String)
    case retrievalError(String)
    
    public var errorDescription: String? {
        switch self {
        case .storageError(let message):
            return "Keychain storage error: \(message)"
        case .retrievalError(let message):
            return "Keychain retrieval error: \(message)"
        }
    }
}
```

## Testing Conventions

### Test Structure
- Use SwiftTesting framework with `@Test` attribute
- Use `@Suite` to group related tests
- Use descriptive test names in Japanese (as per project guidelines)
- Follow Given-When-Then pattern

### Test Example
```swift
import Testing
import Foundation
@testable import ClipboardSecurity

@Suite("SecurityManager Tests")
struct SecurityManagerTests {
    
    @Test("機密データ検出 - パスワードパターン")
    func detectSensitiveContentPassword() async throws {
        // Given
        let sut = SecurityManager()
        
        // When & Then
        #expect(sut.detectSensitiveContent("password: secret123") == true)
        #expect(sut.detectSensitiveContent("Hello World") == false)
    }
}
```

## Project-Specific Conventions

### Package Dependencies
- Always declare minimum required versions
- Use semantic versioning
- Local packages use relative paths
- External packages use GitHub URLs with version constraints

### Security Considerations
- Never log sensitive information
- Use proper encryption for sensitive data
- Follow principle of least privilege
- Validate all inputs

### Performance Guidelines
- Use async/await for concurrent operations
- Prefer value types over reference types when appropriate
- Use lazy initialization for expensive resources
- Implement proper memory management

### SwiftUI Conventions
- Use declarative view structure
- Prefer computed properties for dynamic content
- Use `@State`, `@Binding`, `@ObservableObject` appropriately
- Follow SwiftUI lifecycle patterns