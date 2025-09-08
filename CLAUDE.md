# Dotfiles Configuration - Claude AI Support Guide

Personal dotfiles configuration optimized for software development with a focus on performance, modularity, and seamless tool integration.

## 🎯 Overview

**目的**: 個人開発環境の設定ファイルを統合管理し、モダンな開発体験を提供

### 🔥 Primary Tech Stack

**Core Technologies**: Zsh + WezTerm + Neovim

- この3技術がコード量・使用頻度・機能において中核
- 他ツールはこれらを補完する支援的役割

**Additional Tools**: Tmux, Homebrew, Mise, Raycast, Karabiner Elements

### 設計原則

- **Performance First**: 主要3技術の起動時間最適化（[詳細指標](docs/reference/performance-stats.md)参照）
- **Primary Integration**: Zsh ⇔ WezTerm ⇔ Neovim間のシームレス連携
- **Unified Theme**: Gruvboxベース統一テーマ・フォント設定
- **Modular Design**: 主要技術を中心とした設定の分離・統合

## 📊 Current Status (2025-07-07)

### ✅ Performance Targets Achieved

📊 **最新パフォーマンス結果**: [Performance Statistics](docs/reference/performance-stats.md)

### 🏗️ Architecture

```
dotfiles/
├── zsh/           # Shell configuration (modular, optimized)
├── nvim/          # Neovim configuration (Lua-based)
├── tmux/          # Terminal multiplexer
├── git/           # Version control configuration
├── ssh/           # SSH configuration (hierarchical, secure)
├── alacritty/     # Terminal emulator
├── wezterm/       # Alternative terminal
├── karabiner/     # Keyboard customization
├── raycast/       # Productivity launcher
└── mise.toml      # Version management
```

## 📚 Documentation Structure

**📖 統合ドキュメント**: [./docs/](./docs/) - 体系化されたドキュメント管理システム

### 🏗️ Core Layers (Essential Configurations)

- **[Shell Layer](./docs/configuration/core/shell.md)** - Zsh optimization, plugin management, performance tuning
- **[Git Layer](./docs/configuration/core/git.md)** - Git workflows, authentication, tool integration

### 🔧 Tool Layers (Specialized Implementations)

- **[Editor Layer](./docs/configuration/tools/editor.md)** - Neovim, LSP, AI assistance, plugin optimization
- **[Terminal Layer](./docs/configuration/tools/terminal.md)** - WezTerm, Tmux, Alacritty configurations

### 🚀 Support Layers (Cross-cutting Concerns)

- **[Performance Layer](./docs/configuration/support/performance.md)** - Measurement, optimization, monitoring
- **[Integration Layer](./docs/configuration/support/integration.md)** - Cross-tool workflows, synchronization

### 📋 Architecture Documentation

- **[Design Patterns](./docs/architecture/patterns.md)** - Universal patterns, best practices, reusable solutions

## 📖 Guides

### Implementation & Configuration

- **[Configuration Management](./docs/guides/configuration-management.md)** - パターン、ベストプラクティス、実装手法
- **[Maintenance Guide](./docs/guides/maintenance.md)** - 改善履歴、定期メンテナンス、トラブルシューティング
- **[AI Assistance](./docs/guides/ai-assistance.md)** - AI支援システム、o3 MCP技術相談、層別実装アプローチ

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

- `/task` - インテリジェント・タスク・ルーター（自然言語タスク実行）
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

## 🔗 References

- [Tool List](TOOLS.md)
- [Main README](README.md)
- [統合ドキュメント](./docs/) - 体系化されたドキュメント管理システム
- [Claude Settings](.claude/) - AI支援のための設定とコンテキスト

---

_Last Updated: 2025-09-08_
_Configuration Status: Production Ready - AIコマンドシステム統合完了_
_Performance Targets: All core metrics achieved_
_AI Integration: Global command system with project-specific optimizations_
