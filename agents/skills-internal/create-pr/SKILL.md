---
name: create-pr
description: |
  Automatic format, commit, and GitHub PR creation system with intelligent commit splitting and issue linking.

  [What] Unified workflow: auto-detect formatters → format code → split commits semantically → create/update GitHub PR with Japanese descriptions.

  [When] Use when:
  - Creating PRs from existing code changes
  - Formatting and committing code before PR creation
  - Updating existing PRs with new commits
  - Linking GitHub Issues to PRs automatically
  - Need lightweight PR creation (vs full /task-to-pr workflow)

  [Keywords] pr, pull request, format, commit, github, gh, issue, link, create-pr, フォーマット, コミット
---

# Create PR - 自動フォーマット・コミット・PR作成システム

プロジェクトのフォーマッターを自動検出し、コード整形・適切なコミット分割・GitHub PR作成を一括実行する統合システムです。

## 🇯🇵 重要: 日本語設定

**このスキルで生成されるすべてのPR（プルリクエスト）の内容は日本語で作成されます。**

- PRタイトル（コミットメッセージは英語でも、PR説明は日本語）
- PR本文のセクションヘッダー（概要、変更内容、テスト計画、チェックリスト）
- すべての説明文とチェックリスト項目

## 🔗 共通ユーティリティの活用

このスキルは以下の共通ユーティリティを活用しています:

- **`shared/project-detector.md`**: フォーマッター検出ロジック
- **`shared/task-context.md`**: 統一タスクコンテキスト

## 🚀 Quick Start

### 基本使用

```bash
# 自動検出・実行
/create-pr

# PR タイトル指定
/create-pr "feat: ユーザー認証機能の追加"

# ドラフトPR作成
/create-pr --draft
```

### 主要オプション

```bash
# フォーマット処理スキップ
/create-pr --no-format

# 単一コミットで作成
/create-pr --single-commit

# ベースブランチ指定
/create-pr --base develop

# 既存PR対応
/create-pr --update-if-exists    # 既存PRがあれば自動的に更新
/create-pr --force-new           # 既存PRチェックをスキップして強制新規作成
/create-pr --check-only          # 既存PRの確認のみ（作成/更新なし）

# GitHub Issues連携
/create-pr --link-issues         # Issue検出・リンク有効化（対話的）
/create-pr --auto-link           # 検出されたIssueを自動リンク
/create-pr --no-link-issues      # Issue連携を無効化
```

## 📋 実行フロー概要

```
Phase 1: フォーマッター検出・実行
    ↓
Phase 2: 変更確認
    ↓
Phase 3: インテリジェントコミット分割
    ↓
Phase 3.5: 既存PR検出
    ↓
Phase 3.7: Issue検出・リンキング
    ↓
Phase 4: PR作成/更新（Issue参照付き）
```

### Phase 1: プロジェクト判定・フォーマッター検出

プロジェクトの技術スタックを自動判定し、適切なフォーマッターを選択:

- **Node.js**: package.json検出 → npm/pnpm/yarn/bun run format
- **Go**: go.mod検出 → go fmt/gofumpt
- **Python**: pyproject.toml検出 → black/ruff
- **Rust**: Cargo.toml検出 → cargo fmt

**詳細**: フォーマッター検出は `shared/project-detector.md` を使用します。

### Phase 2: フォーマット実行・変更確認

検出されたフォーマッターを実行し、変更内容を確認:

- フォーマッター未検出時は対話的にコマンドを指定可能
- `--no-format` でスキップ可能
- エラー時は適切なメッセージを表示

### Phase 3: インテリジェントコミット分割

変更内容を解析し、意味的なまとまりごとにコミットを作成:

- **変更タイプ分類**: format, refactor, feature, fix, test, docs, config, deps
- **Conventional Commits準拠**: コミットメッセージ自動生成
- **Co-Author付与**: Claude Code署名を自動追加
- **単一コミットモード**: `--single-commit` で分割せずに作成

**詳細**: コミット分割の完全な仕様は [references/commit-patterns.md](references/commit-patterns.md) を参照してください。

### Phase 3.5: 既存PR検出と対応方針決定

コミット作成後、PRの作成/更新を判断:

- `gh pr list --head <branch>` で既存PR確認
- OPEN/DRAFT状態のPRのみを対象
- 対話的選択: 更新/新規作成/キャンセル
- `--update-if-exists` で自動更新
- `--force-new` で強制新規作成
- `--check-only` で確認のみ

### Phase 3.7: GitHub Issue 検出・リンキング

ブランチ名やコミットメッセージからIssue参照を自動検出し、PR本文に追加:

- **ブランチ名パターン**: `feat/123-description`, `fix/issue-456`, `feature/GH-789`
- **コミットメッセージパターン**: `#123`, `fixes #123`, `closes #456`
- **Issue検証**: `gh issue view` で存在・状態を確認
- **対話的選択**: リンクするIssueとキーワードを選択
- **自動リンク**: `--auto-link` で検出されたオープンIssueを自動リンク

**詳細**: Issue連携の完全な仕様は [references/github-integration.md](references/github-integration.md) を参照してください。

### Phase 4: GitHub PR 作成または更新

既存PR検出結果に基づいてPRを作成または更新:

- **PRタイトル生成**: コミットグループから主要な変更を特定
- **PR本文生成**: 日本語テンプレートまたは `.github/PULL_REQUEST_TEMPLATE.md`
- **Issue参照追加**: "## 関連Issue" セクションを自動挿入
- **リモートプッシュ**: `-u origin <branch>` で追跡設定
- **PRオプション**: `--draft`, `--base`, カスタムテンプレート

**詳細**: PRテンプレートとセクション構造は [references/pr-templates.md](references/pr-templates.md) を参照してください。

## 🎯 特徴

- **プロジェクト自動判定**: package.json/go.mod等から技術スタックを検出
- **フォーマッター統合**: Prettier/gofmt/black等の主要ツール対応
- **スマートコミット分割**: 変更の意味的まとまりを解析
- **既存PR自動検出**: `gh pr list`で既存PRを確認し、重複作成を防止
- **PR柔軟更新**: 既存PRのタイトル・本文を最新のコミットに基づいて更新
- **対話的/自動モード**: ユーザー確認またはオプションで自動実行
- **PR説明自動生成**: コミット内容からサマリーとテスト計画を作成
- **PRテンプレート自動検出**: `.github/PULL_REQUEST_TEMPLATE.md`等を自動で使用
- **エラーハンドリング**: フォーマッター未設定時の適切な処理
- **日本語対応**: PR本文は必ず日本語で生成（タイトル、説明、チェックリスト等すべて）

## 📚 詳細ドキュメント

各Phaseの詳細な実装とアルゴリズムについては、以下のリファレンスを参照してください:

- **コミット分割パターン**: [references/commit-patterns.md](references/commit-patterns.md)
  - Phase 3の完全なコミット分割ロジック
  - Conventional Commits仕様
  - 変更タイプ分類アルゴリズム
  - Co-author attribution

- **PRテンプレート**: [references/pr-templates.md](references/pr-templates.md)
  - PRテンプレート検出パス
  - 日本語PR本文生成ルール
  - セクション構造 (概要, 変更内容, テスト計画, チェックリスト)

- **GitHub統合**: [references/github-integration.md](references/github-integration.md)
  - Phase 3.5: 既存PR検出・更新ロジック
  - Phase 3.7: Issue自動リンク完全仕様
  - `gh` CLI統合ガイド
  - エラーハンドリングパターン

## 🔗 関連スキル

### `/task-to-pr` との棲み分け

- **`/task-to-pr`**: Issue駆動 E2E実装ワークフロー
  - Issue/タスク → worktree → 実装 → PR → CI監視・修正
  - AI主導の実装フロー
  - Phase 0-6の7段階

- **`/create-pr`**: 既存変更のPR化ワークフロー
  - 既存変更 → Format → Commit → PR
  - Human主導の実装 + AI補助のPR化
  - Phase 1-4の4段階

**両者は補完的**: `/task-to-pr`は新規実装、`/create-pr`は既存変更のPR化。

## 制約・注意事項

- Git リポジトリ内で実行する必要があります
- GitHub CLI (`gh`) がインストール・認証済みである必要があります
- フォーマッターは事前にインストールされている必要があります
- main/master ブランチからは自動的に新規ブランチを作成します

### 既存PR対応の制約

- **既存PR検出**: OPENまたはDRAFT状態のPRのみを対象とします
- **PR更新**: タイトルと本文のみを更新します（ラベル、レビュアー、マイルストーンは保持）
- **ブランチ保護**: main/develop等の保護されたブランチへの直接プッシュは失敗します
- **マージ済みPR**: 既にマージされたPRは検出対象外です（新規PR作成）
- **複数PR**: 同じブランチに複数のPRがある場合は最新のものを使用します

### Issue連携の制約

- **GitHub CLI必須**: `gh` コマンドがインストール・認証済みである必要があります
- **Issue検出パターン**: ブランチ名やコミットメッセージの特定パターンのみを認識します
- **Issue検証**: リポジトリ内の存在するIssueのみをリンクできます
- **状態フィルタリング**: オープン状態のIssueのみがデフォルトでリンク対象です

## 🎯 Skill Integration

このスキルは以下のスキルと統合し、PR作成ワークフローを最適化します:

### integration-framework (必須)

- **理由**: TaskContext標準化とPR作成ワークフロー統合
- **タイミング**: スキル実行開始時に自動ロード
- **提供内容**:
  - TaskContextインターフェース（フォーマッター検出・コミット分割・PR作成の状態管理）
  - Communication Busパターン（フェーズ間のデータ共有）
  - エラーハンドリング標準化
  - メトリクス収集とパフォーマンス追跡

### github-cli-helper (オプション)

- **理由**: GitHub PR操作の自動化と統合
- **タイミング**: PR作成・更新フェーズで起動
- **提供内容**:
  - 既存PR検出ロジック
  - PR作成/更新の統一インターフェース
  - Conventional Commits準拠のメッセージ生成
  - エラーリカバリー戦略

### code-review (条件付き)

- **理由**: PR作成前の品質チェック
- **タイミング**: `--pre-review` フラグ使用時
- **提供内容**:
  - 自動コードレビュー
  - 品質スコア算出
  - 修正提案
  - PR本文への品質情報埋め込み

---

**目標**: フォーマット・コミット・PR作成の一連の作業を完全自動化し、開発フローを効率化
