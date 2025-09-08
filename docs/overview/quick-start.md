# Quick Start Guide

高性能macOS開発環境を素早く構築するためのガイドです。

## ⚡ 高速セットアップ

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

## 🎮 Essential Commands

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

## 🤖 AI-Assisted Development

Use `/learnings` command to record new insights into appropriate layers automatically.

技術的な問題に遭遇した場合は、o3 MCPで英語相談 → 日本語で要約説明

## 🔄 Regular Maintenance

- **Weekly**: `brew update && brew upgrade`
- **Monthly**: プラグイン更新とパフォーマンス測定
- **Quarterly**: 設定監査、不要ファイル削除

---

_詳細は [プロジェクト概要](README.md) を参照してください。_
