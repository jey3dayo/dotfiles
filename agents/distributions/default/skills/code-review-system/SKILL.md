---
name: code-review-system
description: Comprehensive code review with multiple modes - detailed (5-star evaluation), simple (parallel agents), PR review, CI diagnostics. Use when reviewing code quality, fixing PR comments, or diagnosing CI failures.
argument-hint: "[--simple] [--staged|--recent|--branch <name>] [--with-impact] [--fix] [--fix-ci [pr-number]] [--fix-pr [pr-number]]"
disable-model-invocation: true
user-invocable: true
allowed-tools: Task, Bash(gh:*), Read, Grep, Glob
---

# Code Review System - 統合コードレビューシステム

包括的なコードレビューを実行するスキルです。複数のレビューモードを提供し、プロジェクトに最適化されたレビューを実施します。

## ⚠️ 重要な注意事項

### GitHub連携について

- このシステムはローカルでのレビューのみを実行します
- GitHub PRへのコメント投稿機能はありません
- レビュー結果はローカルに表示されます
- **すべてのレビュー結果は日本語で出力されます**

### 署名なしポリシー

### IMPORTANT

- ❌ **NEVER** "Co-authored-by: Claude" をcommitに含めない
- ❌ **NEVER** "Generated with Claude Code" を含めない
- ❌ **NEVER** 絵文字をcommits、PRs、issuesに使用しない
- ❌ **NEVER** AI署名やウォーターマークを含めない

## 実行モード

### 1. 詳細モード（デフォルト）

包括的な品質評価を実施：

- ⭐️ 5段階評価体系による次元別評価
- プロジェクトタイプ自動検出
- 技術スタック別スキル統合（typescript, react, golang, security, etc.）
- 詳細な改善提案とアクションプラン

### 使用例

```bash
/review                    # 基本レビュー
/review --with-impact      # 影響分析を含む
/review --fix              # 自動修正を含む
```

### 2. シンプルモード

迅速な問題発見に特化：

- サブエージェント並列実行（security, performance, quality, architecture）
- 優先度付きの問題リスト
- 即座の修正提案
- GitHub issue連携オプション

### 使用例

```bash
/review --simple           # クイックレビュー
/review --simple --fix     # レビュー + 自動修正
```

### 3. CI診断モード

GitHub Actions CI失敗の診断と修正計画の作成を行います。

- `ci-diagnostics` スキルで失敗分類と修正計画を生成
- `gh-fix-ci` スキルでログ取得を補助

### 使用例

```bash
/review --fix-ci           # 現在のブランチのPRを診断
/review --fix-ci 123       # PR番号指定
/review --fix-ci --dry-run # 診断のみ（修正なし）
```

### 4. CI診断 + PRコメント修正モード

CI診断とPRコメント修正を同一フローで実行します。両方の結果を踏まえて修正計画を作成します。

### 使用例

```bash
/review --fix-ci --fix-pr      # 現在のブランチのPRで両方実行
/review --fix-ci 123 --fix-pr  # PR番号指定
/review --fix-ci --fix-pr --dry-run # 診断/分類のみ
```

## 使用方法

### 基本的な使用

```bash
# 詳細モード（デフォルト）
/review

# シンプルモード
/review --simple
```

### 対象ファイル指定

レビュー対象は自動的に以下の優先順位で決定されます：

1. ステージされた変更（`git diff --cached`）
2. 直前のコミット（`git diff HEAD~1`）
3. 開発ブランチとの差分（`git diff origin/develop`など）
4. 最近変更されたファイル

### 明示的指定

```bash
/review --staged           # ステージされた変更のみ
/review --recent           # 直前のコミット
/review --branch develop   # 指定ブランチとの差分
```

### Serena統合（詳細モード）

セマンティック解析機能を追加：

```bash
/review --with-impact      # API変更の影響範囲分析
/review --deep-analysis    # シンボルレベルの詳細解析
/review --verify-spec      # 仕様との整合性確認
```

### ワークフロー統合

```bash
/review --fix              # レビュー + 自動修正
/review --create-issues    # レビュー + GitHub issue作成
/review --learn            # レビュー + 学習データ記録
```

### PRレビュー修正

GitHub PRのレビューコメントを自動修正：

```bash
/review --fix-pr           # 現在のブランチのPR修正
/review --fix-pr 123       # PR番号指定
/review --fix-pr --priority critical  # Critical問題のみ修正
/review --fix-pr --dry-run # ドライラン（修正なし）
```

## オプション一覧

### モード選択

- `--simple`: シンプルモードを使用（デフォルトは詳細モード）
- `--fix-ci [PR番号]`: CI診断モード（GitHub Actions）
- `--fix-ci --fix-pr [PR番号]`: CI診断 + PRコメント修正モード

### 対象指定

- `--staged`: ステージされた変更のみ
- `--recent`: 直前のコミットのみ
- `--branch <name>`: 指定ブランチとの差分

### Serena統合（詳細モードのみ）

- `--with-impact`: API変更の影響分析
- `--deep-analysis`: 深いセマンティック解析
- `--verify-spec`: 仕様との整合性確認

### ワークフロー

- `--fix`: 自動修正を適用
- `--create-issues`: GitHub issue作成
- `--learn`: 学習データ記録

### PRレビュー修正

- `--fix-pr [PR番号]`: PRレビューコメント修正モード
- `--priority <level>`: 修正する優先度（critical/high/major/minor）
- `--bot <name>`: 特定ボットのコメントのみ（例: coderabbitai）
- `--category <cat>`: 特定カテゴリのみ（security/bug/style/etc）
- `--dry-run`: ドライラン（分類のみ、修正なし）

### CI診断

- `--fix-ci [PR番号]`: CI診断モード（GitHub Actions）
- `--dry-run`: ドライラン（診断のみ、修正なし）

## プロジェクト固有カスタマイズ

このシステムは以下の優先順位で動作します：

1. **プロジェクト固有コマンド**: `./.claude/commands/review.md` が存在する場合、それを実行
2. **プロジェクト固有ガイドライン**: `./.claude/review-guidelines.md` が存在する場合、それを適用
3. **汎用レビュー**: 上記がない場合、code-reviewスキルのデフォルト動作

プロジェクト固有の評価ガイドラインを定義するには、以下のいずれかにファイルを配置：

- `./.claude/review-guidelines.md`
- `./docs/review-guidelines.md`
- `./docs/guides/review-guidelines.md`

これらのファイルが存在する場合、自動的に評価ガイドラインに統合されます。

詳細: [project-customization.md](references/project-customization.md)

## 技術スタック別スキル

code-reviewスキルは以下のスキルを自動的に統合します：

- **typescript**: TypeScript固有の観点（型安全性、strictモード、type guards）
- **react**: React固有の観点（hooks、パフォーマンス、コンポーネント設計）
- **golang**: Go固有の観点（error handling、concurrency、idioms）
- **security**: セキュリティ観点（入力検証、認証・認可、データ保護）
- **clean-architecture**: アーキテクチャ観点（層分離、依存規則、ドメインモデリング）

プロジェクトタイプに応じて適切なスキルが自動選択されます。

詳細: [tech-stack-skills.md](references/tech-stack-skills.md)

## 詳細リファレンス

- [実行モード詳細](references/execution-modes.md) - 4モードの詳細仕様と実行フロー
- [スキル統合詳細](references/skill-integration-detail.md) - スキル統合の詳細とフロー
- [プロジェクトカスタマイズ](references/project-customization.md) - ハイブリッド動作とガイドライン
- [技術スタック別スキル](references/tech-stack-skills.md) - プロジェクト判定と評価基準

## 使用例

- [レビューワークフロー](examples/review-workflows.md) - 5つの実践的なワークフロー
- [トラブルシューティング](examples/troubleshooting-solutions.md) - よくある問題と解決方法

## トラブルシューティング

### チェックポイント作成が失敗する

変更がない場合は正常です。既存のチェックポイントがある場合も問題ありません。

### GitHub issue作成が失敗する

```bash
# gh CLIがインストールされているか確認
gh --version

# 認証状態を確認
gh auth status
```

### Serenaオプションが動作しない

Serena MCPサーバーが設定されているか確認してください（`.claude/mcp.json`）。

## 関連コマンド

- `/fix`: 直接エラー修正を実行（error-fixerエージェント）
- `/todos`: TODOリスト管理
- `/learnings`: 学習データ閲覧
- `/task`: 汎用タスク実行

---

### 目標
