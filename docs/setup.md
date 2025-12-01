# 🚀 Setup Guide

**最終更新**: 2025-12-01
**対象**: 開発者・初心者
**タグ**: `category/guide`, `category/configuration`, `layer/core`, `environment/macos`, `audience/beginner`

⚡ High-performance macOS development environment setup. 本ドキュメントがセットアップ情報のSSTであり、README はリンクのみを保持します。

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
zsh-help                # Verify zsh configuration is loaded
zsh-help tools          # Check installed tools
nvim                    # First run installs plugins
git config user.name    # Verify your name appears
```

## Environment-Specific Setup

- **Work Environment**: Add work-specific config to `~/.gitconfig_local`
- **SSH Keys**: Generate with `ssh-keygen -t ed25519 -C "email@example.com"`
- **Terminal**: WezTerm auto-loads config, Alacritty requires restart

## Maintenance

- 定期メンテナンスとトラブルシューティングのSSTは [Maintenance Guide](maintenance.md)
- パフォーマンス測定・改善履歴・診断手順のSSTは [Performance](performance.md)
- セットアップ直後の健全性チェック:

```bash
mise run ci
```
