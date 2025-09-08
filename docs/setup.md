# Setup Guide

⚡ High-performance macOS development environment setup.

## Quick Setup

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

## Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Verification

```bash
zsh-benchmark    # Should show ~1.2s startup
nvim             # First run installs plugins
git config user.name  # Verify your name appears
```

## Environment-Specific Setup

- **Work Environment**: Add work-specific config to `~/.gitconfig_local`
- **SSH Keys**: Generate with `ssh-keygen -t ed25519 -C "email@example.com"`
- **Terminal**: WezTerm auto-loads config, Alacritty requires restart

## Maintenance

```bash
# Weekly updates
brew update && brew upgrade

# Performance monitoring
zsh-benchmark              # Track startup regression

# Monthly: プラグイン更新とパフォーマンス測定
# Quarterly: 設定監査、不要ファイル削除
```
