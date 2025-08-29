# App Store配布設定ガイド

## 概要

AsaClipBoardをApp Storeで配布するための設定とプロセスを説明します。

## 1. プロジェクト設定

### Bundle Identifier
```
com.asaclipboard.AsaClipBoard
```

### Version Information
- **Version**: 1.0.0
- **Build**: 1
- **Minimum macOS Version**: 14.0

### Signing & Capabilities
- **Team**: 開発者アカウント
- **Bundle Identifier**: com.asaclipboard.AsaClipBoard
- **Signing Certificate**: Mac App Distribution
- **Provisioning Profile**: Mac App Store

## 2. 必要な権限設定

### Info.plist設定済み項目
- ✅ NSAccessibilityUsageDescription
- ✅ NSAppleEventsUsageDescription  
- ✅ LSApplicationCategoryType
- ✅ CFBundleLocalizations
- ✅ ITSAppUsesNonExemptEncryption

### Entitlements設定済み項目
- ✅ App Sandbox有効
- ✅ Network Client Access
- ✅ Clipboard Access
- ✅ Apple Events Automation
- ✅ CloudKit Services
- ✅ Keychain Sharing

## 3. アプリアイコン要件

### 必要サイズ（Assets.xcassets設定済み）
- 16x16, 32x32, 128x128, 256x256, 512x512
- @2x Retina対応版
- 1024x1024 App Store用

### デザインガイドライン
- クリップボードをモチーフとしたデザイン
- macOSデザイン言語準拠
- 全サイズで視認性確保

## 4. App Store Connect設定

### アプリ情報
- **App名**: AsaClipBoard
- **カテゴリ**: ユーティリティ
- **価格**: 無料または有料（要決定）

### 説明文案
**日本語:**
```
高機能なクリップボード履歴管理ツール

■ 主な機能
• 自動的にクリップボード履歴を保存
• スマートコンテンツ認識（URL、メール、電話番号など）
• グローバルホットキーで素早くアクセス
• CloudKitによるデバイス間同期
• セキュアなデータ暗号化
• 高速検索とフィルタリング
• カスタマイズ可能な外観設定

■ セキュリティ
• 機密データの自動検出と保護
• Keychain統合によるセキュアな保存
• プライベートモード搭載

■ 動作環境
• macOS 14.0以降
• Intel・Apple Silicon対応
```

**English:**
```
Advanced Clipboard History Manager

■ Key Features
• Automatic clipboard history saving
• Smart content recognition (URLs, emails, phone numbers, etc.)
• Quick access with global hotkeys
• Device synchronization via CloudKit
• Secure data encryption
• Fast search and filtering
• Customizable appearance settings

■ Security
• Automatic sensitive data detection and protection
• Secure storage with Keychain integration
• Private mode support

■ Requirements
• macOS 14.0 or later
• Intel & Apple Silicon compatible
```

### キーワード
- クリップボード, 履歴, コピー, ペースト, 効率化, 生産性
- clipboard, history, productivity, utility, copy, paste

### スクリーンショット要件
1. **メイン画面**: クリップボード履歴表示
2. **検索機能**: フィルタリング動作
3. **設定画面**: カスタマイズオプション
4. **スマート認識**: URL/メール検出例
5. **ホットキー**: 素早いアクセス実演

## 5. 配布プロセス

### Step 1: Archive作成
1. Xcode → Product → Archive
2. Organizer → Distribute App
3. App Store Connect選択

### Step 2: App Store Connectアップロード
1. 証明書とプロファイル確認
2. アーカイブのアップロード
3. 処理完了まで待機

### Step 3: App Store Connect設定
1. アプリバージョン作成
2. メタデータ入力（説明、キーワード等）
3. スクリーンショット追加
4. 価格・提供状況設定

### Step 4: 審査提出
1. 全項目確認
2. 審査用メモ記入（必要に応じて）
3. 審査提出

### Step 5: リリース
1. 審査承認後の対応
2. リリース日程調整
3. プロモーション準備

## 6. 審査ポイント

### 機能性
- ✅ アプリが正常に動作する
- ✅ 説明と実装が一致している
- ✅ クラッシュやエラーがない

### プライバシー
- ✅ アクセス許可の明確な説明
- ✅ データ使用目的の透明性
- ✅ 不要な権限要求なし

### セキュリティ
- ✅ 適切な暗号化実装
- ✅ セキュアなデータハンドリング
- ✅ 脆弱性のないコード

### ユーザーエクスペリエンス
- ✅ 直感的なUI/UX
- ✅ macOSデザインガイドライン準拠
- ✅ アクセシビリティ対応

## 7. トラブルシューティング

### よくある拒否理由
1. **権限説明不足** → Info.plistの説明文確認
2. **機能不明確** → 説明文とスクリーンショット改善
3. **セキュリティ懸念** → 暗号化とプライバシー説明強化
4. **UI/UX問題** → デザインガイドライン再確認

### 対応方法
1. **Rejection理由分析**
2. **該当箇所修正**
3. **テスト環境での再確認**
4. **再提出**

## 8. リリース後の運用

### アップデート計画
- バグフィックス対応
- 機能改善・追加
- macOSバージョン対応

### サポート体制
- ユーザーフィードバック収集
- 問題報告対応
- FAQ整備

### マーケティング
- App Store最適化（ASO）
- ソーシャルメディア活用
- 技術ブログ・記事投稿