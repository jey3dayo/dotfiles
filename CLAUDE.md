# Dotfiles Configuration - Claude AI支援ガイド

このファイルはClaude AIを使用したdotfiles開発を効率的に行うための専用ガイドです。

## 🎯 Overview

**目的**: 個人開発環境の設定ファイルを統合管理し、モダンな開発体験を提供
Personal dotfiles configuration optimized for software development with a focus on performance, modularity, and seamless tool integration.

### 技術スタック詳細

- **Shell**: Zsh + Sheldon プラグイン管理
- **Editor**: Neovim + Lua設定 + AI支援
- **Terminal**: WezTerm (Lua設定) / Alacritty (GPU加速)
- **Multiplexer**: Tmux
- **Package Manager**: Homebrew + Brewfile
- **Version Manager**: Mise
- **Launcher**: Raycast + Karabiner Elements

## 重要な指示

### 🔥 主要技術スタック

**Primary Stack**: Zsh + WezTerm + Neovim

- この3技術がコード量・使用頻度・機能において中核
- 他ツールはこれらを補完する支援的役割

### 設計原則

- **Performance First**: 主要3技術の起動時間最適化（Zsh: 1.2s, Neovim: 95ms, WezTerm: 800ms）
- **Primary Integration**: Zsh ⇔ WezTerm ⇔ Neovim間のシームレス連携
- **Unified Theme**: Gruvboxベース統一テーマ・フォント設定
- **Modular Design**: 主要技術を中心とした設定の分離・統合

## 📊 Current Status (2025-06-09)

### ✅ Completed Components

#### 🐚 Zsh Shell Configuration

- **Performance**: 1.2s startup (30% improvement achieved - 1.7s → 1.2s)
- **Architecture**: Modular loader system with lazy evaluation (config/loader.zsh + 機能別ローダー)
- **Features**: Git integration, FZF search, abbreviations, comprehensive help system
- **Key Commands**: `zsh-help`, `zsh-benchmark`, `zsh-profile`
- **Optimizations**: mise超遅延化（39.88ms削減）、6段階プラグイン順序、全ファイルコンパイル
- **Status**: Production-ready with ongoing performance monitoring

##### Zsh Key Features

- **Abbreviations**: 50+ コマンド短縮形
- **Git Widgets**: `^g^g`, `^g^s`, `^g^a`, `^g^b` でGit操作
- **FZF統合**: `^]` リポジトリ選択、`^g^K` プロセス管理
- **Help System**: `zsh-help [keybinds|aliases|tools]` で詳細ヘルプ

#### 🚀 Neovim Editor

- **Performance**: Optimized startup with lazy.nvim plugin management
- **Architecture**: Lua-based modular configuration
- **Features**: Full LSP support, AI assistance (Copilot/Avante), modern UI
- **Status**: Feature-complete with iterative improvements

#### 🔧 Terminal & Multiplexer

- **Alacritty**: GPU-accelerated terminal with custom theming
- **Tmux**: Session management with plugin ecosystem
- **Wezterm**: Alternative terminal with comprehensive Lua configuration

##### WezTerm Detailed Configuration

- **Architecture**: Modular Lua-based system (wezterm.lua, ui.lua, keybinds.lua, utils.lua)
- **Platform Support**: Cross-platform (macOS/Windows) with WSL integration
- **Theme**: Gruvbox dark with custom tab styling and 92% transparency
- **Font**: UDEV Gothic 35NFLG (16pt) with Nerd Font fallbacks
- **Performance**: WebGpu backend for GPU acceleration

##### WezTerm Key Bindings

- **Leader Key**: `Ctrl+x` (tmux-style) for tab/pane management
- **Navigation**: Alt+hjkl for pane movement, Alt+Tab for tab switching
- **Copy Mode**: Leader+[ for vim-like text selection (hjkl, v/V, y/yy, /search)
- **Pane Operations**: Leader + split/zoom/rotate commands

#### 🛠️ Development Tools

- **Git**: Enhanced with custom aliases and integrations
- **SSH**: Hierarchical configuration with 1Password integration
- **Mise**: Version management for multiple languages
- **Brewfile**: Declarative package management
- **Various**: Language-specific tools and linters

## 🏗️ Architecture

### Core Principles

1. **Modularity**: Each tool configured independently but integrated seamlessly
2. **Performance**: Lazy loading and optimization throughout
3. **Portability**: macOS-focused with cross-platform considerations
4. **Maintainability**: Clear structure with comprehensive documentation

### Directory Structure

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

## 🔑 Key Commands & Workflows

### Zsh Environment

```bash
# Performance & debugging
zsh-help                    # Comprehensive help system
zsh-benchmark              # Startup time measurement
zsh-profile                # Performance profiling

# Git workflows (via abbreviations & widgets)
^]                         # fzf ghq repository selector
^g^g, ^g^s, ^g^a, ^g^b    # Git status/add/branch widgets
```

### Development Environment

```bash
# Version management
mise install              # Install language versions
mise use                  # Set project versions

# Package management
brew bundle               # Install/update all packages
```

## 📈 Performance Metrics

### Zsh Shell

- **Startup Time**: 1.2s (target achieved)
- **Optimization**: mise lazy loading (-39.88ms)
- **Plugin Management**: Sheldon with 6-tier priority loading

### Neovim

- **Startup**: <100ms with lazy.nvim
- **Plugin Count**: Optimized for essential functionality
- **LSP Support**: 15+ languages configured

## 🔧 Key Integrations

### Cross-Tool Synergy

- **Zsh ↔ Git**: Custom widgets and abbreviations
- **Zsh ↔ FZF**: Repository/file/process selection
- **Nvim ↔ Terminal**: Seamless editing workflows
- **SSH ↔ Git**: Secure authentication with 1Password integration
- **Tmux ↔ All**: Session persistence across tools

### External Dependencies

- **1Password**: SSH key management and CLI integration
- **GitHub CLI**: Repository management
- **Raycast**: System-wide shortcuts and scripts
- **Karabiner**: Keyboard layout optimization

## 🎨 Theming & UI

### Consistent Design

- **Color Scheme**: Gruvbox/Tokyo Night across tools
- **Fonts**: JetBrains Mono with ligatures
- **Icons**: Nerd Fonts for enhanced visual feedback

## 🚀 Future Roadmap

### Planned Improvements

1. **Automation**: Enhanced setup scripts and bootstrapping
2. **Documentation**: Interactive help system expansion
3. **Performance**: Continued optimization across all tools
4. **Integration**: Deeper cross-tool workflow automation

### Experimental Features

- **AI Integration**: Enhanced Copilot workflows
- **Cloud Sync**: Configuration synchronization
- **Mobile**: iOS Shortcuts integration

## 📋 Maintenance

### Regular Tasks

- Weekly: `brew update && brew upgrade`
- Monthly: Plugin updates and performance reviews
- Quarterly: Configuration audit and cleanup

### Monitoring

- Startup time tracking (zsh-benchmark)
- Plugin usage analysis
- Performance regression detection

## 🔧 Configuration Management

### 設定パターン & ベストプラクティス

#### モジュラー設計原則

- **機能別分離**: 各ツールの独立した設定構成
- **遅延読み込み**: 必要時のみプラグイン・設定を読み込み
- **条件分岐**: OS・環境別の適応的設定

#### パフォーマンス最適化手法

```bash
# Zsh 起動時間測定
time zsh -i -c exit
zsh-benchmark              # カスタムベンチマークツール

# Neovim プロファイリング
nvim --startuptime startup.log
:Lazy profile              # プラグイン統計
```

#### 設定ファイル管理パターン

```bash
# シンボリックリンク作成
ln -sf "$DOTFILES_DIR/config_file" "$HOME/.config_file"

# 条件付き設定読み込み
[[ -f "$HOME/.local_config" ]] && source "$HOME/.local_config"

# OS別設定分岐
case "$(uname -s)" in
    Darwin)  # macOS specific
        ;;
    Linux)   # Linux specific
        ;;
esac
```

## 🚧 Development Status

### ✅ Completed (2025-01-04)

- **Zsh Performance**: 1.2s startup achieved (30% improvement)
- **Neovim Optimization**: <100ms startup with LSP integration
- **Documentation Restructure**: README.md simplified, layer-based organization
- **LSP Error Resolution**: vscode-langservers-extracted MethodNotFound fixed

### 🔄 In Progress

- **Configuration Consolidation**: Reducing plugin count, streamlining configs
- **Layer-based Documentation**: Systematic knowledge organization

### 📋 Planned Improvements

- **Automation**: Enhanced setup scripts and bootstrapping
- **Performance**: Continue micro-optimizations across tools
- **Integration**: Deeper cross-tool workflow automation

## 📚 改善履歴

### 2025-06-09: Zsh パフォーマンス最適化

- **問題**: 起動時間2秒超で開発体験悪化
- **解決**: Sheldon 6段階読み込み、mise遅延読み込み実装
- **成果**: 1.2秒達成（30%改善）

### 2025-06-08: Neovim 大規模リファクタリング

- **問題**: 設定散在、依存関係複雑
- **解決**: Lua設定移行、lazy.nvim最適化、LSPモジュール化
- **成果**: 起動100ms以下、15言語LSP対応

### 2025-06-07: Git統合強化

- **問題**: Git操作煩雑、非効率フロー
- **解決**: Zsh略語展開、FZF統合、ghq管理
- **成果**: Git操作時間50%短縮

## 🛠️ よく使用するパターン

### Git ワークフロー

```bash
# 高速Git操作（Zsh略語）
g    # git
ga   # git add
gc   # git commit
gp   # git push

# FZF統合ブランチ切り替え
function gco() {
    git checkout $(git branch -a | fzf | sed 's/remotes\/origin\///')
}
```

### 開発環境セットアップ

```bash
# 言語バージョン管理
mise install node@20.10.0
mise use node@20.10.0

# パッケージ管理
brew bundle                # Brewfile からインストール
brew update && brew upgrade # 定期更新
```

### デバッグ & トラブルシューティング

```bash
# 設定診断
which command_name         # コマンドパス確認
type command_name          # コマンド種別確認
echo $PATH                 # PATH環境変数確認

# Zsh診断
zsh -x -c 'exit'          # デバッグモード実行
zmodload zsh/zprof; zprof  # プロファイリング
```

## 📚 Layer-based Knowledge System

Technical knowledge is organized into **specialized layers** for efficient implementation and maintenance:

### 🏗️ Core Layers (Essential Configurations)

- **[Shell Layer](.claude/layers/core/shell-layer.md)** - Zsh optimization, plugin management, performance tuning
- **[Git Layer](.claude/layers/core/git-layer.md)** - Git workflows, authentication, tool integration

### 🔧 Tool Layers (Specialized Implementations)

- **[Editor Layer](.claude/layers/tools/editor-layer.md)** - Neovim, LSP, AI assistance, plugin optimization
- **[Terminal Layer](.claude/layers/tools/terminal-layer.md)** - WezTerm, Tmux, Alacritty configurations

### 🚀 Support Layers (Cross-cutting Concerns)

- **[Performance Layer](.claude/layers/support/performance-layer.md)** - Measurement, optimization, monitoring
- **[Integration Layer](.claude/layers/support/integration-layer.md)** - Cross-tool workflows, synchronization

### 📋 Architecture Documentation

- **[Design Patterns](.claude/architecture/patterns.md)** - Universal patterns, best practices, reusable solutions

### 🤖 AI-Assisted Development

Use `/learnings` command to record new insights into appropriate layers automatically.

### 🤖 AI支援システム

#### o3 MCP技術相談

実装中に技術的に詰まった場合や解決できないエラーに遭遇した場合は、o3 MCPに英語で相談できます：

**対象場面**:

- 複雑なエラーメッセージの解読
- 技術的実装方針の判断
- パフォーマンス問題の診断
- ライブラリ・フレームワークの使用方法
- 設定ファイルの構文・仕様確認

**相談方法**:

```
技術的な質問やエラー内容を英語でo3 MCPに投げることで、専門的なアドバイスを受けられます
相談後は必ず日本語で回答内容を要約・説明します
```

**例**:

- "How to optimize Zsh startup time when using multiple plugins?"
- "LSP client configuration issue in Neovim with TypeScript"
- "WezTerm Lua configuration error: attempt to index nil value"

## 実装ワークフロー

### 🚀 層別実装アプローチ

#### Step 1: 実装準備

1. **対象層ドキュメント確認**: 該当層の `.claude/layers/` ドキュメントを読み込み
2. **アーキテクチャ理解**: `.claude/architecture/patterns.md` で統一方針を確認
3. **依存関係把握**: 他層との連携パターンを理解

#### Step 2: 実装実行

1. **既存設定優先**: 新規作成より既存設定の編集・拡張を検討
2. **パフォーマンス重視**: 起動時間・レスポンス時間への影響を常に考慮
3. **統一パターン活用**: 各層ドキュメント内の実装テンプレートを利用

#### Step 3: 品質確保

1. **測定・検証**: 該当層の測定パターンに従い実装効果を検証
2. **統合テスト**: 他ツールとの連携に問題がないことを確認
3. **知見記録**: `/learnings` コマンドで新しい知見を層別に記録

## 🔗 References

- [Tool List](TOOLS.md)
- [Main README](README.md)
- [Claude Settings](.claude/) - AI支援のための設定とコンテキスト

---

_Last Updated: 2025-06-20_
_Configuration Status: Production Ready - 層別知識管理システム統合完了_
