# Personal Dotfiles

Modern macOS development environment optimized for performance, modularity, and seamless tool integration.

## ✨ Features & Performance

- **🐚 Zsh**: 1.2s startup (30% improvement) with modular plugin system
- **🚀 Neovim**: <100ms startup with 15+ language LSP support
- **🔧 Terminal**: GPU-accelerated (Alacritty/WezTerm) with unified theming
- **⚡ Git**: Enhanced workflow with custom widgets and 50+ abbreviations
- **🎨 Theming**: Consistent Gruvbox/Tokyo Night + JetBrains Mono across tools

## 🚀 Quick Start

```bash
# Clone repository
git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
cd ~/src/github.com/jey3dayo/dotfiles

# Run setup
sh ./setup.sh

# Install packages
brew bundle
```

## 📝 Detailed Setup Guide

### Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install git stow
```

### Step-by-Step Installation

#### 1. Repository Setup

```bash
# Create directory structure
mkdir -p ~/src/github.com/jey3dayo

# Clone dotfiles
git clone https://github.com/jey3dayo/dotfiles ~/src/github.com/jey3dayo/dotfiles
cd ~/src/github.com/jey3dayo/dotfiles

# Initialize submodules
git submodule update --init --recursive
```

#### 2. Git Configuration

**⚠️ Important**: Configure your personal Git settings before running setup.

```bash
# Create personal Git configuration (NOT tracked in repository)
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# Set appropriate permissions
chmod 600 ~/.gitconfig_local
```

**Git Configuration Structure**:
- `~/.gitconfig` → Main entry point (created by setup)
- `~/.gitconfig_local` → Personal info (Git-ignored, secure)
- `~/.config/git/config` → Shared dotfiles settings

#### 3. Run Setup Script

```bash
# Execute automated setup
sh ./setup.sh
```

**What setup.sh does**:
- Creates XDG base directories (`~/.config`, `~/.cache`)
- Links dotfiles to `~/.config` via symlink
- Configures Git to use dotfiles settings
- Sets up Zsh environment variables
- Initializes submodules

#### 4. Package Installation

```bash
# Install all packages from Brewfile
brew bundle

# Verify installation
brew bundle check
```

#### 5. Shell Configuration

```bash
# Restart shell to load Zsh configuration
exec zsh

# Verify Zsh performance
zsh-benchmark

# Install shell plugins
# (Plugins will auto-install on first shell start)
```

### Post-Installation Configuration

#### SSH Setup (Optional)

```bash
# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to SSH agent
ssh-add ~/.ssh/id_ed25519

# Copy public key and add to GitHub
pbcopy < ~/.ssh/id_ed25519.pub
# Then paste in GitHub Settings > SSH Keys
```

#### Terminal Setup

**For WezTerm** (Recommended):
```bash
# WezTerm will auto-load configuration from ~/.config/wezterm/
# No additional setup required
```

**For Alacritty**:
```bash
# Configuration auto-linked via ~/.config/alacritty/
# Restart Alacritty to apply settings
```

#### Neovim Setup

```bash
# First run will install plugins automatically
nvim

# Verify LSP installation
:checkhealth
```

### Environment-Specific Configuration

#### Personal vs Work Setup

**Work environment**:
```bash
# Override Git config for work projects
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Work Name
    email = your.work@company.com

[includeIf "gitdir:~/work/"]
    path = ~/.config/git/work.gitconfig
EOF
```

**Personal projects**:
```bash
# Default configuration in ~/.gitconfig_local works for personal use
```

### Verification & Testing

```bash
# Test Git configuration
git config --list | grep user

# Test SSH connection
ssh -T git@github.com

# Test shell performance
zsh-benchmark

# Test Neovim
nvim --startuptime startup.log
```

## 📁 Structure

```
dotfiles/
├── zsh/           # Zsh configuration (1.2s startup, modular)
├── nvim/          # Neovim configuration (Lua-based, LSP)
├── git/           # Git configuration with widgets
├── alacritty/     # GPU-accelerated terminal
├── wezterm/       # Lua-based terminal alternative
├── tmux/          # Session management
├── karabiner/     # Keyboard optimization
├── raycast/       # Productivity launcher
├── Brewfile       # Package management
└── mise.toml      # Runtime management
```

## 🛠️ Key Tools & Configurations

### Shell & Editor
- **Zsh + Sheldon**: 6-tier priority loading, 39.88ms mise optimization
- **Neovim + Lazy.nvim**: AI assistance (Copilot/Avante), 15+ LSP
- **Git integration**: Custom widgets, FZF search, abbreviations

### Terminal Experience  
- **Alacritty**: High-performance GPU acceleration
- **WezTerm**: Lua configuration, tmux-style leader key (`Ctrl+x`)
- **Tmux**: Session persistence with plugin ecosystem

### Development Tools
- **Mise**: Multi-language version management with lazy loading
- **1Password**: SSH key management and CLI integration
- **GitHub CLI**: Repository automation
- **FZF**: Unified search (files, repos, processes, history)

## 🎮 Essential Commands

```bash
# Zsh help system
zsh-help                    # Comprehensive help
zsh-help keybinds          # Key bindings
zsh-help aliases           # Abbreviations (50+)
zsh-benchmark              # Performance measurement

# Git workflow (via Zsh widgets)
^]                         # FZF repository selector
^g^g, ^g^s, ^g^a, ^g^b    # Git status/add/branch widgets

# WezTerm (Ctrl+x leader)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation
```

## 📈 Performance Metrics

| Component | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Zsh startup | 1.7s | 1.2s | 30% faster |
| Neovim startup | ~200ms | <100ms | 50% faster |
| mise loading | baseline | -39.88ms | Critical optimization |

### Optimization Techniques
- **Lazy loading**: Plugins load only when needed
- **6-tier priority**: Essential tools load first
- **GPU acceleration**: Hardware-optimized rendering
- **Modular design**: Independent but integrated components

## 🎨 Unified Design

- **Colors**: Gruvbox/Tokyo Night theme across all tools
- **Typography**: JetBrains Mono with Nerd Font ligatures
- **Transparency**: 92% opacity for modern glass effects
- **Icons**: Consistent icon system for visual feedback

## 🔧 Advanced Features

### Git Integration
- **Custom widgets**: Instant status, staging, branch switching
- **50+ abbreviations**: `g` (git), `ga` (git add), `gc` (git commit)
- **FZF integration**: Visual branch selection and file search

### WezTerm Configuration
- **Modular Lua**: ui.lua, keybinds.lua, utils.lua structure
- **Cross-platform**: macOS/Windows with WSL support
- **Vim-style copy mode**: hjkl navigation, visual selection
- **Custom tab styling**: Arrow separators, process name display

### AI Development Environment
- **GitHub Copilot**: Code completion and suggestions
- **Avante.nvim**: AI chat integration in Neovim
- **Claude Code**: Repository context and documentation

## 📦 Package Management

```bash
# Homebrew packages
brew bundle                # Install from Brewfile
brew bundle dump --force   # Update Brewfile
brew bundle cleanup        # Remove unused packages

# Runtime versions
mise install              # Install configured versions
mise use node@20          # Set project-specific version

# Global npm packages
npm list -g --json > global-packages.json
```

## 🔗 Documentation

- **[CLAUDE.md](CLAUDE.md)**: Comprehensive configuration guide and technical details
- **[TOOLS.md](TOOLS.md)**: Complete tool inventory and usage patterns
- **Component READMEs**: Detailed configuration for each tool

## 📋 Maintenance

### Regular Tasks
- **Weekly**: `brew update && brew upgrade`
- **Monthly**: Plugin updates and performance reviews
- **Quarterly**: Configuration audit and optimization

### Monitoring
- **Startup tracking**: `zsh-benchmark` for performance regression
- **Plugin analysis**: Usage patterns and optimization opportunities
- **Performance profiling**: `zsh-profile` for detailed analysis

## 📝 License

MIT License - Feel free to use and adapt for your own setup.

---

*Optimized for modern development workflows with focus on speed, consistency, and developer experience.*