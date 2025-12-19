# 🚀 Setup Guide

**最終更新**: 2025-12-18
**対象**: 開発者・初心者
**タグ**: `category/guide`, `category/configuration`, `layer/core`, `environment/macos`, `audience/beginner`

⚡ High-performance macOS development environment setup. 本ドキュメントがセットアップ情報のSSTであり、README はリンクのみを保持します。

## Bootstrap (Recommended for Fresh macOS)

新規Macの場合、`bin/bootstrap`を使用してHomebrewを自動インストール:

```bash
cd ~/src/github.com/jey3dayo/dotfiles
sh ./bin/bootstrap
```

**実行内容**:

- Homebrewインストール（存在しない場合）
- アーキテクチャ検出（Apple Silicon vs Intel）
- システム前提条件検証（macOS、git、zsh、curl）
- 現在のセッションで`brew`コマンドを使用可能に設定
- 次ステップへのガイド表示

**その後、以下のQuick Setupステップに従ってください。**

---

## Quick Setup

**前提条件**: Homebrewがインストール済み（上記bootstrap実行、または既にインストール済み）

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
sh ./bin/setup && brew bundle

# 4. Restart shell
exec zsh
```

## Prerequisites

### Automated (Recommended)

Use bootstrap script for automated Homebrew installation:

```bash
sh ./bin/bootstrap
```

### Manual Installation

If you prefer manual installation:

```bash
# Install Homebrew
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

## Troubleshooting

### Bootstrap後に "Command not found: brew"

現在のシェルにHomebrewを追加:

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"
```

その後、`exec zsh`でシェルを再起動すれば永続的に有効になります。

### Bootstrapがネットワークエラーで失敗

- インターネット接続を確認
- リトライ: `sh ./bin/bootstrap`
- または手動でHomebrewをインストール（前提条件セクション参照）

### Homebrewが既に存在する場合

- Bootstrapは既存インストールを検出して安全にスキップ
- 複数回実行しても問題なし

### その他のトラブルシューティング

詳細なトラブルシューティング手順は [Maintenance Guide](maintenance.md) を参照してください。
