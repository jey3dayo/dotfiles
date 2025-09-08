# Personal Dotfiles

⚡ **High-performance macOS development environment** - Optimized for speed, consistency, and developer experience.

## 🚀 Performance Achievements

📊 **詳細なパフォーマンス指標**: [Performance Statistics](../reference/performance-stats.md)

| Component           | Current   | Improvement |
| ------------------- | --------- | ----------- |
| **Zsh startup**     | **1.2s**  | 30% faster  |
| **Neovim startup**  | **<95ms** | 50% faster  |
| **WezTerm startup** | **800ms** | 35% faster  |

## ✨ Core Features

- **🐚 Zsh**: Modular plugin system with 6-tier priority loading (1.2s startup)
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

## 📝 Detailed Setup

<!-- Details section for complete installation guide -->

### Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Complete Installation Steps

1. **Repository Setup**

   ```bash
   mkdir -p ~/src/github.com/jey3dayo
   git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
   cd ~/src/github.com/jey3dayo/dotfiles
   ```

2. **Git Configuration** (Critical)

   ```bash
   # Personal configuration (not tracked in git)
   cat > ~/.gitconfig_local << EOF
   [user]
       name = Your Name
       email = your.email@example.com
   EOF
   chmod 600 ~/.gitconfig_local
   ```

3. **Automated Setup**

   ```bash
   sh ./setup.sh    # Links configs, sets up environment
   brew bundle      # Installs all packages
   exec zsh         # Loads new shell configuration
   ```

4. **Verification**

   ```bash
   zsh-benchmark    # Should show ~1.2s startup
   nvim             # First run installs plugins
   git config user.name  # Verify your name appears
   ```

### Environment-Specific Setup

- **Work Environment**: Add work-specific config to `~/.gitconfig_local`
- **SSH Keys**: Generate with `ssh-keygen -t ed25519 -C "email@example.com"`
- **Terminal**: WezTerm auto-loads config, Alacritty requires restart

</details>

## 🏗️ Project Architecture

### Full Directory Structure

```
dotfiles/
├── docs/              # 統合ドキュメント管理
├── zsh/               # Shell configuration (modular, optimized)
├── nvim/              # Neovim configuration (Lua-based)
├── git/               # Version control configuration
├── wezterm/           # Primary terminal configuration
├── alacritty/         # Alternative terminal
├── tmux/              # Terminal multiplexer
├── ssh/               # SSH configuration (hierarchical, secure)
├── karabiner/         # Keyboard customization
├── mise.toml          # Version management
├── Brewfile           # Package management
└── setup.sh           # Automated setup script
```

### 🔥 Primary Tech Stack

**Core Technologies**: Zsh + WezTerm + Neovim

- この3技術がコード量・使用頻度・機能において中核
- 他ツールはこれらを補完する支援的役割

**Additional Tools**: Tmux, Homebrew, Mise, Raycast, Karabiner Elements

### Design Principles

#### Performance First

- 主要3技術の起動時間最適化
- 詳細指標は[Performance Statistics](../reference/performance-stats.md)参照

#### Primary Integration

- Zsh ⇔ WezTerm ⇔ Neovim間のシームレス連携
- 統一されたキーバインドとワークフロー

#### Unified Theme

- Gruvboxベース統一テーマ・フォント設定
- JetBrains Mono + Nerd Font ligatures

#### Modular Design

- 主要技術を中心とした設定の分離・統合
- 6-tier plugin loading system
- 階層化された設定ファイル構造

### 🔄 Configuration Management

#### Layered Approach

1. **Core Layers**: 基本設定（Shell, Git）
2. **Tool Layers**: 専門ツール（Editor, Terminal）
3. **Support Layers**: 横断的機能（Performance, Integration）

#### Modular Design

- 各ツールは独立した設定ディレクトリを持つ
- 共通設定は上位レイヤーで統一管理
- 依存関係を最小化したプラグインシステム

## 🎮 Essential Commands

```bash
# Shell optimization
zsh-benchmark              # Measure startup time (~1.2s)
zsh-help [keybinds|aliases] # Interactive help system

# Git workflow (custom widgets)
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
- **FZF**: Unified search (files, repos, processes)
- **GitHub CLI**: Repository automation
- **1Password**: SSH key management

### Design System

- **Theme**: Gruvbox/Tokyo Night consistency
- **Typography**: JetBrains Mono + Nerd Font ligatures
- **Performance**: GPU acceleration, lazy loading

## 📚 Documentation

- **[CLAUDE.md](../../CLAUDE.md)**: Technical implementation guide & AI assistance
- **[Configuration Layers](../configuration/)**: Layered knowledge system (Shell, Git, Editor, Terminal)
- **[Guides](../guides/)**: Implementation guides, maintenance procedures, and AI assistance
- **[Reference](../reference/)**: Performance statistics, tool configurations, keybindings
- **[Tools](../tools/)**: Tool-specific documentation and configuration details

## 🔧 Maintenance

```bash
# Weekly updates
brew update && brew upgrade

# Performance monitoring
zsh-benchmark              # Track startup regression
zsh-profile               # Detailed performance analysis

# Configuration audit (quarterly)
# - Plugin usage review
# - Performance optimization
# - Configuration cleanup
```

---

**Status**: Production-ready (2025-07-06)
**License**: MIT - Optimized for modern development workflows with focus on speed, consistency, and developer experience.
