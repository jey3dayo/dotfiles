# Dotfiles Configuration - Claude AI Support Guide

Personal dotfiles configuration optimized for software development with a focus on performance, modularity, and seamless tool integration.

## 🎯 Project Context

**目的**: 個人開発環境の設定ファイルを統合管理し、モダンな開発体験を提供

### 📂 Steering Documents (Always Included - AI Context)

**Location**: [`.kiro/steering/`](.kiro/steering/) - AI セッションで常時ロードされる高レベルコンテキスト

- **[Product Overview](.kiro/steering/product.md)** - プロダクト概要、機能、ユースケース、価値提案
- **[Technology Stack](.kiro/steering/tech.md)** - アーキテクチャ、技術スタック、開発環境、コマンド
- **[Project Structure](.kiro/steering/structure.md)** - ディレクトリ構造、設計パターン、命名規則

詳細な実装ガイドやメトリクスは `docs/` ディレクトリを参照してください。

### 🔥 Core Technologies

**Primary Stack**: Zsh + WezTerm + Neovim（コード量・使用頻度・機能において中核）
**Supporting Tools**: Tmux, Homebrew, Mise, Raycast, Karabiner Elements

### 📊 Performance Status

| Component           | Current    | Target |
| ------------------- | ---------- | ------ |
| **Zsh startup**     | **1.1s**   | <100ms |
| **Neovim startup**  | **<100ms** | <200ms |
| **WezTerm startup** | **800ms**  | <1s    |

詳細: [Performance Statistics](docs/performance.md)

## 📚 Documentation Structure

### 📂 Steering (AI Context - Always Included)

**Location**: [`.kiro/steering/`](.kiro/steering/)

プロジェクトの高レベルコンテキスト（プロダクト概要、技術スタック、構造）を提供。AI セッションで常時参照されます。

### 📖 Detailed Documentation (Human Reference)

**Location**: [`./docs/`](./docs/) - 実装詳細、メトリクス、ガイド

- **[Documentation Navigation](./docs/README.md)** - ドキュメント体系の案内
- **[Setup Guide](./docs/setup.md)** - インストール・初期設定
- **[Performance](./docs/performance.md)** - 詳細メトリクス、ベンチマーク
- **[Maintenance](./docs/maintenance.md)** - メンテナンス手順、トラブルシューティング
- **[Documentation Guidelines](./docs/documentation-guidelines.md)** - タグ体系、メタデータ、品質基準

### 🛠️ Tool-Specific Documentation

- **[Zsh](./docs/tools/zsh.md)** - Shell最適化、プラグイン管理、パフォーマンス
- **[Neovim](./docs/tools/nvim.md)** - LSP、AI支援、プラグイン最適化
- **[WezTerm](./docs/tools/wezterm.md)** - 設定、キーバインド、統合
- **[SSH](./docs/tools/ssh.md)** - 階層的設定、セキュリティ
- **[FZF Integration](./docs/tools/fzf-integration.md)** - クロスツール統合

## 📖 Quick Links

- **[Setup Guide](./docs/setup.md)** - 環境セットアップ手順
- **[Maintenance Guide](./docs/maintenance.md)** - 定期メンテナンス、トラブルシューティング
- **[Documentation Navigation](./docs/README.md)** - 全ドキュメント体系へのナビゲーション

## 🚀 Quick Start

### Essential Commands

```bash
# Performance & debugging
zsh-help                    # Comprehensive help system
zsh-benchmark              # Startup time measurement

# Git workflows (via abbreviations & widgets)
^]                         # fzf ghq repository selector
^g^g, ^g^s, ^g^a, ^g^b    # Git status/add/branch widgets

# Version management
mise install              # Install language versions
mise use                  # Set project versions

# Package management
brew bundle               # Install/update all packages
```

### 🤖 AI-Assisted Development

Use `/learnings` command to record new insights into appropriate layers automatically.

技術的な問題に遭遇した場合は、o3 MCPで英語相談 → 日本語で要約説明

## 🤖 AI Command System

### 統合コマンドシステム

本dotfilesプロジェクトは、グローバルAIコマンドシステムと統合されています：

#### グローバルコマンド（全プロジェクト共通）

- `/task` - インテリジェント・タスク・ルーター（自然言語タスク実行)
- `/todos` - 統合タスク管理・実行システム
- `/review` - 統合コードレビューシステム（ハイブリッド動作）
- `/learnings` - 学習記録システム
- `allow-command` - Claude設定許可管理ユーティリティ

#### プロジェクト固有コマンド（dotfiles特化）

- `/refactoring` - dotfiles特化リファクタリング
- `/update-readme` - ツール別README自動更新

#### 特化レビュー基準

- `.claude/review-criteria.md` - dotfiles特化の5段階評価システム
- 層別分析（Shell/Editor/Terminal/Git）
- パフォーマンス影響評価（起動時間・メモリ使用量）

## 🔄 Maintenance

### Regular Tasks

- **Weekly**: `brew update && brew upgrade`
- **Monthly**: プラグイン更新とパフォーマンス測定
- **Quarterly**: 設定監査、不要ファイル削除

### Monitoring

- 起動時間追跡 (`zsh-benchmark`)
- プラグイン使用状況分析
- パフォーマンス回帰検出

### Local CI Checks

GitHub Actions CI と同等のチェックをローカルで実行：

```bash
# 全てのCIチェックを実行
./.claude/commands/ci-local.sh

# または mise 経由で実行
mise run ci

# 環境セットアップ（初回のみ）
./.claude/commands/ci-local.sh setup

# 個別チェック
mise run format:biome:check
mise run format:markdown:check
mise run format:yaml:check
mise run lint:lua
mise run format:lua:check
mise run format:shell:check
```

## 🔗 References

- [Tool List](TOOLS.md)
- [Main README](README.md)
- [統合ドキュメント](./docs/) - 体系化されたドキュメント管理システム
- [Claude Settings](.claude/) - AI支援のための設定とコンテキスト
- [TODO](docs/TODO.md) - タスク管理・課題追跡

---

_Last Updated: 2025-10-16_
_Configuration Status: Production Ready - Documentation refactored_
_Performance Targets: Zsh 1.1s, Neovim <100ms achieved_
_AI Integration: Global command system with project-specific optimizations_
