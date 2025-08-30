# 継続的インテグレーション (CI) セットアップ

AsaClipBoardプロジェクト用のGitHub Actions CI/CDパイプラインが設定されました。

## ワークフロー概要

### 📋 メインワークフロー (`ci.yml`)

**トリガー:**
- `main`, `develop` ブランチへのプッシュ
- `main`, `develop` ブランチへのプルリクエスト

**実行環境:**
- macOS Latest
- Xcode 15.0, 15.1（マトリックス）

### 🔍 実行ジョブ

#### 1. **Test Suite** 
- 全Swiftパッケージのテスト実行
- 並列テスト実行でパフォーマンス向上
- パッケージ: ClipboardCore, ClipboardSecurity, ClipboardUI, IntegrationTests

#### 2. **Build App**
- AsaClipBoard.app の完全ビルド
- Release設定での検証
- コード署名なしでの構成

#### 3. **Code Quality (Lint)**
- SwiftLint による静的解析
- SwiftFormat によるコードフォーマット検証
- 厳格モード有効

#### 4. **Security Scan**
- GitGuardian による秘密情報スキャン
- セキュリティ脆弱性の検出

#### 5. **Code Coverage**  
- 全パッケージのカバレッジ生成
- Codecov 連携（オプショナル）

#### 6. **Notifications**
- CI結果の統合レポート
- 成功/失敗の明確な通知

## 📝 設定ファイル

### `.swiftlint.yml`
- Kiro-styleコード品質基準
- 120文字行制限
- カスタムルール有効
- テストファイル除外

### `.swiftformat`
- 統一されたコードフォーマット
- 4スペースインデント
- アルファベット順インポート
- Swift 5.9対応

## 🔧 ローカル実行

### テスト実行
```bash
# 全パッケージのテスト
cd ClipboardCore && swift test --parallel
cd ClipboardSecurity && swift test --parallel  
cd ClipboardUI && swift test --parallel
cd IntegrationTests && swift test --parallel
```

### コード品質チェック
```bash
# SwiftLint
brew install swiftlint
swiftlint --strict

# SwiftFormat
brew install swiftformat
swiftformat --lint .
```

### アプリビルド
```bash
xcodebuild -project AsaClipBoard.xcodeproj \
           -scheme AsaClipBoard \
           -destination 'platform=macOS' \
           -configuration Release \
           build
```

## 🔐 必要なシークレット（オプション）

GitHub リポジトリ設定で以下のシークレットを設定可能：

- `GITGUARDIAN_API_KEY`: セキュリティスキャン用
- `CODECOV_TOKEN`: コードカバレッジ連携用

## 📊 品質メトリクス

- **テストカバレッジ**: 全パッケージで測定
- **静的解析**: SwiftLint 準拠
- **セキュリティ**: GitGuardian スキャン
- **ビルド検証**: Release 設定

## 🚀 今後の拡張

1. **パフォーマンステスト**: XCTest Performance
2. **UI自動化テスト**: Playwright統合
3. **依存関係スキャン**: Dependabot
4. **アーティファクト生成**: .app バンドル生成
5. **デプロイメント**: TestFlight / App Store Connect

---

**作成日**: 2025-08-30  
**対応バージョン**: Swift 5.9, Xcode 15.x  
**メンテナー**: Kiro Development Team