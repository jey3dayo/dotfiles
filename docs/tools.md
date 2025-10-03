# 🔧 Tools Configuration

**最終更新**: 2025-10-03
**対象**: 開発者
**タグ**: `category/reference`, `tool/git`, `layer/core`, `environment/macos`

Essential tools and their key configurations.

## Core Stack

### Zsh + WezTerm + Neovim

- **Zsh**: 6-tier priority loading, mise optimization
- **WezTerm**: Primary terminal with Lua configuration
- **Neovim**: AI assistance (Supermaven)

### Additional Tools

- **Tmux**: Terminal multiplexer
- **Mise**: Multi-language version management
- **FZF**: Unified search (files, repos, processes)
- **GitHub CLI**: Repository automation

## Essential Commands

```bash
# Performance & debugging
zsh-help                    # Comprehensive help system
zsh-benchmark              # Startup time measurement

# Git workflows (via abbreviations & widgets)
^]                         # fzf ghq repository selector
^g^g, ^g^s, ^g^a, ^g^b    # Git status/add/branch widgets

# WezTerm (Ctrl+x leader key)
Ctrl+x c                   # New tab
Ctrl+x [                   # Vim-style copy mode
Alt+hjkl                   # Pane navigation

# Version management
mise install              # Install language versions
mise use                  # Set project versions

# Package management
brew bundle               # Install/update all packages
```

## Managed Tools

### Shell・Terminal

- Zsh, zsh-abbr, Starship, Alacritty, WezTerm, Tmux, SSH

### Development

- Git, GitHub CLI, Neovim, efm-langserver, mise, Homebrew, AWSume, Terraform

### Linters・Formatters

- Biome, Hadolint, shellcheck, pycodestyle, Stylua, Taplo, Yamllint, Typos

### Applications

- Btop, htop, Flipper, Karabiner, Vimium
