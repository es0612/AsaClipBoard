# Suggested Commands for AsaClipBoard Development

## XcodeGen Commands
```bash
# Generate Xcode project from project.yml
xcodegen generate

# Generate with specific spec file
xcodegen generate --spec project.yml
```

## Building and Testing
```bash
# Open project in Xcode
open AsaClipBoard.xcodeproj

# Build for macOS using xcodebuild
xcodebuild -project AsaClipBoard.xcodeproj -scheme AsaClipBoard -destination 'platform=macOS' build

# Run tests for main project
xcodebuild test -project AsaClipBoard.xcodeproj -scheme AsaClipBoard -destination 'platform=macOS'

# Test individual SPM packages (faster)
cd ClipboardSecurity && swift test
cd ClipboardCore && swift test  
cd ClipboardUI && swift test

# Test all packages in parallel
swift test --parallel
```

## Package Management
```bash
# Resolve Swift Package Manager dependencies
xcodebuild -resolvePackageDependencies

# Clean and rebuild packages
cd ClipboardSecurity && swift package clean && swift build
cd ClipboardCore && swift package clean && swift build
cd ClipboardUI && swift package clean && swift build
```

## Kiro Spec-Driven Development Commands
```bash
# Check current specification status
/kiro:spec-status macos-clipboard-manager

# Continue implementation of current tasks
/kiro:spec-impl macos-clipboard-manager [task-number]

# Create new feature specification
/kiro:spec-init [feature-description]

# Update steering documents
/kiro:steering
```

## Git Commands (macOS-specific)
```bash
# Standard git operations work on macOS
git status
git add .
git commit -m "message"
git push

# View recent commits
git log --oneline -10

# Check working directory changes
git diff
```

## System Utilities (macOS)
```bash
# List directory contents
ls -la

# Find files
find . -name "*.swift" -type f

# Search in files (use ripgrep if available, otherwise grep)
rg "pattern" --type swift
grep -r "pattern" --include="*.swift" .

# Navigate directories
cd ClipboardSecurity
pwd

# Check processes
ps aux | grep Xcode
```

## Performance and Debugging
```bash
# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean Swift package caches
swift package clean

# Check Swift version
swift --version

# Check Xcode version
xcodebuild -version
```