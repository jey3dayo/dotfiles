# Dotfiles Configuration - Claude Context

## 🎯 Overview

Personal dotfiles configuration optimized for software development with a focus on performance, modularity, and seamless tool integration.

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

## 🚧 現在のタスク

### 🔴 高優先度
1. **Zsh パフォーマンス最適化** - 起動時間1.0秒以下を目標
2. **Neovim 設定整理** - 未使用プラグインの削除、設定簡素化

### 🟡 中優先度
3. **設定自動同期** - Git hooks による設定変更の自動コミット
4. **セットアップ改善** - 新環境での一発セットアップスクリプト

### 🟢 低優先度
5. **ドキュメント充実** - 各設定の詳細説明、使い方追記
6. **バックアップ機能** - 定期的な設定バックアップとバージョン管理

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

## 🔗 References

- [Tool List](TOOLS.md)
- [Main README](README.md)
- [Claude Settings](.claude/) - AI支援のための設定とコンテキスト

---

*Last Updated: 2025-06-14*
*Configuration Status: Production Ready - Continuous Optimization*