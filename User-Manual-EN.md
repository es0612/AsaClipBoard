# AsaClipBoard User Manual

**Version**: 1.0.0  
**Compatible OS**: macOS 14.0 or later  
**Last Updated**: August 29, 2024

## Table of Contents

1. [Introduction](#1-introduction)
2. [Installation and Setup](#2-installation-and-setup)
3. [Basic Usage](#3-basic-usage)
4. [Advanced Features](#4-advanced-features)
5. [Settings and Customization](#5-settings-and-customization)
6. [Security and Privacy](#6-security-and-privacy)
7. [Troubleshooting](#7-troubleshooting)
8. [FAQ](#8-faq)
9. [Support](#9-support)

## 1. Introduction

### 1.1 What is AsaClipBoard

AsaClipBoard is a powerful clipboard history manager for macOS. It automatically saves text, images, and other content you copy, making them easily accessible at any time.

### 1.2 Key Features

- **📋 Automatic History Saving**: Automatically saves copied content
- **🔍 Smart Content Recognition**: Auto-detects URLs, email addresses, phone numbers, etc.
- **⌨️ Global Hotkeys**: Quick access from anywhere in the system
- **☁️ CloudKit Sync**: Data synchronization across multiple Mac devices
- **🔒 Security Features**: Automatic protection of sensitive data
- **🎨 Customizable**: Freely customize appearance and behavior

### 1.3 System Requirements

- **OS**: macOS 14.0 (Sonoma) or later
- **CPU**: Intel or Apple Silicon
- **RAM**: 4GB or more recommended
- **Storage**: 100MB or more free space
- **Permissions**: Accessibility permission required

## 2. Installation and Setup

### 2.1 Installing from App Store

1. Open the **App Store**
2. Search for **"AsaClipBoard"**
3. Click **"Get"** or **"Install"**
4. Sign in with your **Apple ID** for authentication

### 2.2 Initial Setup

#### Step 1: Configure Accessibility Permissions

1. Launch AsaClipBoard
2. Click **"Open System Preferences"**
3. Go to **Privacy & Security** → **Accessibility**
4. Click the **🔓lock icon** and enter your password
5. Check the box next to **"AsaClipBoard"**

#### Step 2: Configure Apple Events Permissions

1. Go to **Privacy & Security** → **Automation**
2. Expand **"AsaClipBoard"**
3. Check the necessary items

#### Step 3: Basic Configuration

1. Return to AsaClipBoard
2. Click the **gear icon** to open settings
3. Configure as desired:
   - **History Count**: 100-1000 items
   - **Hotkey**: Default `⌘+Shift+V`
   - **Auto-launch**: Recommended ON

## 3. Basic Usage

### 3.1 Viewing Clipboard History

#### From Menu Bar

1. Click the **clipboard icon in the menu bar**
2. Recent items appear in popup
3. Click an item to set it to clipboard

#### Using Hotkeys

1. Press **⌘+Shift+V** (default setting)
2. History window appears
3. Navigate with **↑↓ arrow keys**
4. Press **Enter** to select, **Escape** to cancel

### 3.2 Basic Operations

#### Copy and Auto-save

1. Copy text or images with **⌘+C** in any app
2. AsaClipBoard automatically saves to history
3. Menu bar icon blinks to notify save completion

#### Selecting and Using Items

1. Select an item from history
2. Automatically set to clipboard
3. Paste with **⌘+V** in target app

#### Managing Items

- **Right-click**: Display context menu
- **Swipe**: Add to favorites, delete
- **Double-click**: Display detailed view

### 3.3 Search and Filtering

#### Search Function

1. Click the **search bar** in history window
2. Enter keywords
3. Results are filtered in real-time

#### Filtering

1. Select from the **filter bar**:
   - **All**: Display all items
   - **Text**: Text only
   - **Images**: Images only
   - **URLs**: Items containing URLs
   - **Favorites**: Favorited items

## 4. Advanced Features

### 4.1 Smart Content Recognition

AsaClipBoard automatically analyzes copied content and suggests appropriate actions.

#### Supported Content

- **URLs**: Open in browser
- **Email addresses**: Create email
- **Phone numbers**: Call with Phone app
- **Addresses**: Show in Maps
- **Color codes**: Display color preview
- **Code**: Syntax highlighting

#### Executing Actions

1. Select the relevant item
2. Click the **Smart Action** button
3. Choose from suggested actions

### 4.2 Categories and Favorites

#### Creating Categories

1. Right-click an item
2. Select **"Add to Category"** → **"New Category"**
3. Enter category name
4. Choose icon and color

#### Managing Favorites

1. Right-click an item
2. Click **"Add to Favorites"**
3. **★ icon** appears
4. Favorite items are not auto-deleted

### 4.3 CloudKit Sync

#### Enabling Sync

1. **Settings** → **Sync**
2. Turn ON **"Enable iCloud Sync"**
3. Sign in with **Apple ID**
4. Select sync targets:
   - Clipboard history
   - Favorites
   - Categories
   - Settings

#### Checking Sync Status

- **Menu Bar**: Check status with sync icon
- **Settings Screen**: Display last sync time
- **Notifications**: Notify when sync completes

### 4.4 Advanced Search Features

#### Regular Expression Search

1. Turn ON **"Regular Expression"** in search bar
2. Enter regex pattern
3. Example: `\d{3}-\d{4}-\d{4}` (phone number search)

#### Search History

- Auto-save past search queries
- Click **search bar** to display history
- Save frequently used searches as **bookmarks**

## 5. Settings and Customization

### 5.1 General Settings

#### Startup Settings

- **Auto-launch**: Start automatically on macOS boot
- **Window Display**: Display behavior on startup
- **Update Check**: Automatic update check frequency

#### History Settings

- **Maximum Count**: Choose from 100-1000 items
- **Auto-delete**: Deletion settings for old items
- **Duplicate Handling**: How to handle duplicate items
- **Preview Length**: Character count for preview text

### 5.2 Hotkey Settings

#### Global Hotkeys

1. **Settings** → **Hotkeys**
2. Click **"Show History"**
3. Enter **key combination**
4. **Conflict Check** verifies overlap with other apps

#### Recommended Hotkeys

- **⌘+Shift+V**: Show history (default)
- **⌘+Shift+C**: Re-copy latest item
- **⌘+Shift+X**: Clear history

### 5.3 Appearance Settings

#### Theme Settings

- **Light Mode**: Bright appearance
- **Dark Mode**: Dark appearance
- **Follow System**: Sync with macOS settings

#### Font Settings

- **Font Family**: System font or custom
- **Font Size**: Choose from 10-20pt
- **Line Spacing**: Adjust text display spacing

#### Color Themes

1. **Settings** → **Appearance** → **Color Theme**
2. Choose from:
   - **Blue** (default)
   - **Gray**
   - **Purple**
   - **Green**
   - **Custom** (choose from color wheel)

### 5.4 Notification Settings

#### Notification Types

- **Banner**: Display at top of screen
- **Alert**: Notifications requiring confirmation
- **None**: Disable notifications

#### Notification Content

- **New item saved**: ON/OFF
- **Sync completed**: ON/OFF
- **Error occurred**: ON/OFF
- **Memory usage warning**: ON/OFF

## 6. Security and Privacy

### 6.1 Private Mode

#### Function Overview

Private Mode temporarily stops clipboard history recording.

#### Usage

1. Right-click **menu bar** icon
2. Select **"Private Mode"**
3. **🔒 icon** displays while recording is stopped
4. Select again to return to normal mode

### 6.2 Sensitive Data Protection

#### Auto-detection Patterns

The following patterns are automatically recognized as sensitive data:

- **Passwords**: Text containing "password:" or "パスワード："
- **Credit Cards**: Card number patterns
- **Social Security**: 12-digit number patterns
- **Email**: Domain format containing @

#### Protection Levels

1. **Level 1 (Basic)**: Password patterns only
2. **Level 2 (Standard)**: Includes financial information
3. **Level 3 (High)**: All personal information

### 6.3 Encryption Settings

#### Local Encryption

- **AES-256 Encryption**: Encrypt sensitive data locally
- **Keychain Integration**: System-level secure storage
- **Encryption Keys**: Device-specific keys

#### Cloud Encryption

- **End-to-End Encryption**: Encryption during CloudKit sync
- **Device-Specific Keys**: Independent keys for each device
- **Zero Knowledge**: Apple cannot decrypt content

### 6.4 Data Deletion

#### Secure Deletion

1. **Settings** → **Privacy** → **Data Deletion**
2. Select deletion targets:
   - Data from specific periods
   - Data from specific categories
   - All data
3. Click **"Execute Secure Deletion"**
4. Data is deleted in an unrecoverable manner

## 7. Troubleshooting

### 7.1 Common Problems and Solutions

#### App Won't Start

**Symptoms**: AsaClipBoard won't start or exits immediately

**Solutions**:
1. Check for existing processes in **Activity Monitor**
2. Quit existing processes if found
3. Restart from **Applications** folder
4. Reinstall if problem persists

#### Hotkeys Not Responding

**Symptoms**: History window doesn't appear when pressing set hotkeys

**Solutions**:
1. **System Preferences** → **Privacy & Security** → **Accessibility**
2. Verify AsaClipBoard is checked
3. Uncheck and recheck
4. Restart AsaClipBoard

#### History Not Being Saved

**Symptoms**: Copied items not added to history

**Solutions**:
1. Check if **Private Mode** is ON
2. Check if copying from **unsupported app**
3. Check for **memory shortage**
4. Verify **Settings** → **General** → **History Settings**

#### CloudKit Sync Fails

**Symptoms**: Data not syncing between devices

**Solutions**:
1. Check **internet connection**
2. Check **iCloud sign-in status**
3. Check **iCloud storage capacity**
4. **Settings** → **Sync** → **"Reset Sync"**

#### Slow Performance

**Symptoms**: App runs slowly, poor responsiveness

**Solutions**:
1. Reduce **history count** (recommend under 500)
2. **Delete old data**
3. Check **memory usage**
4. **Restart macOS**

### 7.2 Error Messages

#### "Insufficient Access Permissions"

**Cause**: Required system permissions not granted

**Solution**:
1. **System Preferences** → **Privacy & Security**
2. Add AsaClipBoard to **Accessibility**
3. Allow access to necessary apps in **Automation**

#### "Sync Failed"

**Cause**: iCloud connection or account issue

**Solution**:
1. Check **iCloud settings**
2. Check **network connection**
3. Re-sign in to **Apple ID**
4. **Reset sync settings**

#### "Out of Memory"

**Cause**: Insufficient available memory

**Solution**:
1. **Close other apps** to free memory
2. **Reduce history count**
3. **Delete large image data**
4. **Restart macOS**

### 7.3 Checking Log Files

#### Log File Location

```
~/Library/Application Support/AsaClipBoard/Logs/
```

#### How to Check Logs

1. **Finder** → **Go** → **Go to Folder**
2. Enter the above path
3. Check **latest log file**
4. Review error messages

## 8. FAQ

### 8.1 General Questions

**Q: Is AsaClipBoard free?**  
A: Basic features are free. Advanced features (CloudKit sync, unlimited history, etc.) are available in the paid version.

**Q: Is there a Windows version?**  
A: Currently macOS only. No Windows version planned at this time.

**Q: Where is data stored?**  
A: Locally in ~/Library/Application Support/AsaClipBoard/, and synced to iCloud when using CloudKit.

**Q: How do I uninstall?**  
A: Delete from Launchpad or Applications folder. For complete data removal, execute "Delete All Data" from settings.

### 8.2 Feature Questions

**Q: What file formats are supported?**  
A: Text, images (PNG, JPEG, GIF), rich text (RTF), URLs, and more.

**Q: What's the maximum history count?**  
A: Free version: 100 items, paid version: up to 10,000 items.

**Q: What if sensitive information is accidentally saved?**  
A: Immediately right-click → "Secure Delete" for complete removal. We also recommend using Private Mode.

**Q: Can I use it with other clipboard managers?**  
A: Technically possible but not recommended to avoid conflicts and unexpected behavior.

### 8.3 Technical Questions

**Q: How much memory does it use?**  
A: Typically 50-100MB in normal use. Varies with history count and image data volume.

**Q: What's the CPU usage?**  
A: Under 1% normally. Temporarily increases during copy detection and smart content analysis.

**Q: Does it perform network communication?**  
A: Only when CloudKit sync is enabled, communicating with iCloud servers.

**Q: Can I use it offline?**  
A: Yes, all basic functions work offline. Only sync features require online environment.

## 9. Support

### 9.1 Support Channels

**Email Support**  
📧 support@asaclipboard.com  
⏰ Weekdays 9:00-17:00 (JST)  
📅 Response time: 1-2 business days

**Community Support**  
🌐 https://community.asaclipboard.com  
💬 User-to-user information exchange  
📚 FAQ and tips

### 9.2 Feedback

**Feature Improvement Suggestions**  
📧 feedback@asaclipboard.com  
💡 New feature ideas  
🐛 Bug reports

**App Store Reviews**  
⭐ Rate and review on App Store  
📝 Reference information for other users

### 9.3 Update Information

**Release Notes**  
🆕 New feature introductions  
🔧 Improvements and fixes  
⚠️ Known issues

**Beta Testing**  
🧪 Early access to new features  
📧 Beta tester recruitment information

---

We hope this manual helps you use AsaClipBoard effectively. If you have any questions or concerns, please don't hesitate to contact support.

**AsaClipBoard Team**