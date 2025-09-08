# Personal Dotfiles

⚡ **High-performance macOS development environment** - Optimized for speed, consistency, and developer experience.

## 🚀 Performance Achievements

📊 **詳細なパフォーマンス指標**: [Performance Statistics](.claude/reference/performance-stats.md)

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

<details>
<summary>Click to expand complete installation guide</summary>

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

- **[CLAUDE.md](CLAUDE.md)**: Technical implementation guide & AI assistance
- **[.claude/layers/](.claude/layers/)**: Layered knowledge system (Shell, Git, Editor, Terminal)
- **[.claude/architecture/](.claude/architecture/)**: Architecture patterns and design principles
- **Component configs**: Each tool includes detailed configuration docs

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
