---
name: git-worktree
description: |
  Git worktree management using git-wt (k1LoW) and native git worktree commands.
  Use when: (1) Managing multiple feature branches in parallel,
  (2) Need to switch between branches without stashing,
  (3) Setting up AI agent parallel workflows,
  (4) Working with .worktrees directory structure.
  Keywords: worktree, git-wt, parallel development, branch isolation, .worktrees
---

# Git Worktree Management

Git worktreeを使った並列開発のための包括的なガイド。`git-wt`（k1LoW版）とネイティブ`git worktree`コマンドの効果的な使い方を提供します。

## Quick Start

### 基本コマンド

```bash
# Worktree一覧表示
git wt list

# 新規worktree作成（新しいブランチ）
git wt create feature/new-feature

# 既存ブランチでworktree作成
git wt create -b existing-branch

# Worktreeに切り替え
git wt switch feature/new-feature

# Worktree削除（安全）
git wt remove feature/new-feature

# Worktree削除（強制）
git wt remove -f feature/new-feature
```

### git wt vs git worktree

- **git wt**: k1LoW版の高機能ラッパー（hooks、ファイルコピー、シェル統合対応）
- **git worktree**: Git公式のネイティブコマンド（シンプル、標準的）

### 推奨

## Core Concepts

### Worktreeとは

Git worktreeは、同一リポジトリの異なるブランチを別々のディレクトリで同時に作業できる機能です。

### 利点

- ブランチ切り替え時のstash不要
- 並列開発が容易（複数PRの同時作業）
- ビルド/テストの並列実行
- AI agentによるタスク並列化

### 制限

- 同じブランチは複数のworktreeで同時チェックアウト不可
- メインリポジトリ（`.git`ディレクトリがある場所）は保護すべき

### .worktrees ディレクトリ構造

このリポジトリでは `.worktrees/` を標準ディレクトリとして使用：

```
/path/to/repo/
├── .git/
├── .worktrees/
│   ├── feature-a/       # ブランチ: feature/a
│   ├── feature-b/       # ブランチ: feature/b
│   └── hotfix-123/      # ブランチ: hotfix/123
├── main-branch-files...
└── ...
```

### 設定

### 代替

### デフォルトブランチの保護

メインリポジトリ（`main`/`master`/`develop`）は作業用として使わず、worktreeのみで作業するのがベストプラクティス：

```bash
# メインリポジトリはクリーンに保つ
cd /path/to/repo
git status  # Should be clean

# 作業はworktreeで
cd .worktrees/feature-x
# ... work here ...
```

## Common Operations

### 新規Worktree作成

### 新しいブランチで作成

```bash
# 基本形（ブランチ名からworktree名を自動生成）
git wt create feature/user-auth
# → .worktrees/user-auth/ が作成される

# Worktree名を明示指定
git wt create feature/user-auth --path .worktrees/auth-feature

# 特定のコミットから作成
git wt create feature/bugfix --start-point v1.2.3
```

### 既存ブランチで作成

```bash
# リモートブランチから
git wt create -b origin/feature/existing

# ローカルブランチから
git wt create -b feature/local-branch
```

### Worktree切り替え

```bash
# ブランチ名で切り替え
git wt switch feature/user-auth

# Worktreeパスで切り替え
git wt switch .worktrees/user-auth

# 対話的選択（fuzzy finder）
git wt switch
```

### Note

### Worktree削除

### 安全な削除

```bash
git wt remove feature/user-auth
```

### 強制削除

```bash
git wt remove -f feature/user-auth
```

### 未追跡のworktreeをクリーンアップ

```bash
git worktree prune
```

### リスト表示と情報確認

```bash
# シンプルなリスト
git wt list

# 詳細情報（ブランチ、コミット、ステータス）
git wt list --verbose

# ネイティブコマンドで確認
git worktree list
```

## Configuration

### 主要設定項目

```bash
# Worktreeのベースディレクトリ（必須）
git config wt.basedir ".worktrees"

# デフォルトのworktree名生成パターン
git config wt.nameTemplate "{{.BranchName}}"

# 自動的にupstreamを設定
git config wt.autoSetupRemote true
```

### グローバル設定

```bash
git config --global wt.basedir ".worktrees"
```

### リポジトリローカル設定

```bash
git config --local wt.basedir ".worktrees"
```

詳細設定オプションは [`references/configuration.md`](references/configuration.md) を参照。

## Advanced Features

### Hooks

Worktree作成/削除時に自動実行されるフック:

- `.git/hooks/post-worktree-add`: Worktree作成後
- `.git/hooks/post-worktree-remove`: Worktree削除後

### 使用例

詳細は [`references/workflows.md`](references/workflows.md#hooks) を参照。

### ファイルコピーオプション

Worktree作成時に特定のファイルをコピー:

```bash
# .env ファイルをコピー
git wt create feature/test --copy .env

# 複数ファイル
git wt create feature/test --copy .env --copy config.local.json
```

設定で自動コピーも可能:

```bash
git config wt.copyFiles ".env,config.local.json"
```

### シェル統合

### Zsh統合

`zsh/config/tools/git.zsh`に以下の関数が実装済み:

- `gwt`: git wt のエイリアス
- `gwtl`: git wt list
- `gwtc`: git wt create（対話的選択）
- `gwts`: git wt switch（対話的選択）
- `gwtr`: git wt remove（対話的選択）

### 使い方

```bash
# 対話的にworktreeを作成
gwtc

# 対話的にworktreeに切り替え
gwts

# リスト表示
gwtl
```

## Real-World Workflows

### AI Agent並列実行

複数のAI agentがそれぞれのworktreeで作業:

```bash
# Agent 1: Feature A
git wt create feature/agent-task-a
cd .worktrees/agent-task-a
# ... agent works here ...

# Agent 2: Feature B（並列実行）
git wt create feature/agent-task-b
cd .worktrees/agent-task-b
# ... agent works here ...
```

### PR同時作業

複数のPRを同時に進める:

```bash
# PR #123の修正
git wt create -b pr-123-fixes

# PR #124のレビュー対応（並行作業）
git wt create -b pr-124-review

# メインの開発（さらに並行）
git wt create feature/new-feature
```

### ビルド/テストの並列実行

```bash
# メインworktreeでテスト実行中
cd .worktrees/feature-a
npm test &

# 別worktreeで開発継続
cd .worktrees/feature-b
# ... continue working ...
```

詳細なワークフローパターンは [`references/workflows.md`](references/workflows.md) を参照。

## Troubleshooting

### よくある問題

### 問題

```bash
# 原因: 同じブランチが別のworktreeで使用中
# 解決: 別のブランチ名を使うか、既存worktreeを削除

git wt list  # 使用中のブランチを確認
git wt remove feature/x  # 必要に応じて削除
```

### 問題

```bash
# 原因: Gitメタデータのみ削除された
# 解決: 手動でディレクトリ削除 + prune

rm -rf .worktrees/old-worktree
git worktree prune
```

### 問題

```bash
# 診断スクリプトで確認
scripts/check-worktree-config.sh

# 設定の確認
git config wt.basedir
git config --list | grep wt.
```

詳細なトラブルシューティングは [`references/troubleshooting.md`](references/troubleshooting.md) を参照。

## References

- **[Command Reference](references/git-wt-commands.md)**: 全コマンドの詳細リファレンス
- **[Configuration](references/configuration.md)**: 全設定オプション詳細
- **[Workflows](references/workflows.md)**: 実践的なワークフローパターン
- **[Troubleshooting](references/troubleshooting.md)**: 問題解決ガイド

## External Resources

- [git-wt GitHub Repository](https://github.com/k1LoW/git-wt)
- [Git Official Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Worktrunk - AI Agent Parallel Workflows](https://github.com/max-sixty/worktrunk)

## Integration Notes

### Zsh Functions

このリポジトリの`zsh/config/tools/git.zsh`に以下が実装済み:

- Worktree管理関数（`gwt*`エイリアス）
- 対話的選択（fzf統合）
- 自動補完

### Git Config

デフォルト設定（`git/config`）:

```ini
[wt]
    basedir = .worktrees
```

### Ignore Files

以下のファイルで`.worktrees/`が除外設定済み:

- `.gitignore`
- `.fdignore`
- `.prettierignore`
- `mise/config.toml`（タスク除外）

---

### Version

### Last Updated

### Target
