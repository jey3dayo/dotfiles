# Personal Dotfiles

⚡ **High-performance macOS development environment** - Optimized for speed, consistency, and developer experience.

## 🚀 Performance Achievements

📊 **詳細なパフォーマンス指標**: [Performance Statistics](docs/performance.md)

| Component           | Current    | Improvement |
| ------------------- | ---------- | ----------- |
| **Zsh startup**     | **1.1s**   | 43% faster  |
| **Neovim startup**  | **<100ms** | 50% faster  |
| **WezTerm startup** | **800ms**  | 35% faster  |

## ✨ Core Features

- **🐚 Zsh**: Modular plugin system with 6-tier priority loading (1.1s startup)
- **🚀 Neovim**: 15+ language LSP support with AI assistance (Supermaven)
- **🔧 Terminal**: WezTerm (primary) + Alacritty with tmux-style workflow
- **⚡ Git**: 50+ abbreviations and custom widgets for enhanced workflow
- **🎨 Theming**: Unified Gruvbox design across all tools
- **🛠️ Version Management**: Mise for language versions, Homebrew for packages

## ⚡ Quick Setup

```bash
# 1. Clone repository
git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
cd ~/src/github.com/jey3dayo/dotfiles

# 2. Configure Git (REQUIRED)
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# 3. Run automated setup
sh ./setup.sh && brew bundle

# 4. Restart shell
exec zsh
```

📖 **詳細なセットアップ手順**: [Setup Guide](docs/setup.md)

## 📁 Architecture

```
dotfiles/
├── zsh/           # Shell (1.2s startup, 6-tier loading)
├── nvim/          # Editor (Lua config, 15+ LSP)
├── git/           # Version control (widgets, 50+ abbrevs)
├── wezterm/       # Terminal (Lua config, tmux-style)
├── alacritty/     # Alternative terminal (GPU-accelerated)
├── tmux/          # Session management
├── Brewfile       # Package management
└── .claude/       # AI assistance & documentation
```

## 🎮 Essential Commands

```bash
# Shell optimization
zsh-help                   # Interactive help system
zsh-help keybinds          # Key bindings reference
zsh-help aliases           # Aliases reference

# Git workflow (custom widgets)
# See: docs/tools/fzf-integration.md for complete FZF guide
Ctrl+]                     # FZF repository selector
Ctrl+g Ctrl+g             # Git status widget
Ctrl+g Ctrl+s             # Git add widget

# WezTerm (Ctrl+x leader key)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation

# Package management
brew bundle                # Install all packages
mise install              # Setup language versions
```

## 🛠️ Key Technologies

### Core Stack

- **Zsh + Sheldon**: 6-tier priority loading, 39ms mise optimization
- **Neovim + Lazy.nvim**: AI assistance (Supermaven), sub-95ms startup
- **WezTerm**: Primary terminal with Lua configuration and tmux-style workflow
- **Alacritty**: GPU-accelerated alternative terminal

### Development Tools

- **Mise**: Multi-language version management
- **FZF**: Unified search ([Integration Guide](docs/tools/fzf-integration.md))
- **GitHub CLI**: Repository automation
- **1Password**: SSH key management

### Design System

- **Theme**: Gruvbox/Tokyo Night consistency
- **Typography**: JetBrains Mono + Nerd Font ligatures
- **Performance**: GPU acceleration, lazy loading

## 📚 Documentation

- **[Setup Guide](docs/setup.md)** - 詳細なインストール手順
- **[Tools List](TOOLS.md)** - 管理対象ツール一覧
- **[Documentation Index](docs/README.md)** - 全ドキュメント体系へのナビゲーション
- **[Steering Documents](.kiro/steering/)** - AIセッション向けハイレベルコンテキスト

## 🔧 Maintenance

```bash
# Weekly updates
brew update && brew upgrade

# Performance monitoring
zsh-help tools             # Check installed tools
zsh-help                   # Verify configuration

# Configuration audit (quarterly)
# - Plugin usage review
# - Performance optimization
# - Configuration cleanup

# Local CI checks
mise run ci                # Run all CI checks locally
```

---

**Status**: Production-ready (2025-10-16)
**License**: MIT - Optimized for modern development workflows with focus on speed, consistency, and developer experience.
