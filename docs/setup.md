# 🚀 Setup Guide

**最終更新**: 2026-01-20
**対象**: 開発者・初心者
**タグ**: `category/guide`, `category/configuration`, `layer/core`, `environment/macos`, `audience/beginner`

⚡ High-performance macOS development environment setup. 本ドキュメントがセットアップ情報のSSTであり、README はリンクのみを保持します。

## Bootstrap (Recommended for Fresh macOS)

新規Macの場合、`scripts/bootstrap.sh`を使用してHomebrewを自動インストール:

```bash
cd ~/.config
sh ./scripts/bootstrap.sh
```

### 実行内容

- Homebrewインストール（存在しない場合）
- アーキテクチャ検出（Apple Silicon vs Intel）
- システム前提条件検証（macOS、git、zsh、curl）
- 現在のセッションで`brew`コマンドを使用可能に設定
- 次ステップへのガイド表示

その後、以下のQuick Setupステップに従ってください。

---

## Quick Setup

**前提条件**: Homebrew と Nix がインストール済み（上記bootstrap実行、または既にインストール済み）

```bash
# 1. Clone repository
git clone https://github.com/jey3dayo/dotfiles ~/.config
cd ~/.config

# 2. Configure Git (REQUIRED)
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# 3. Install Homebrew packages (includes Nix)
brew bundle

# 4. Apply dotfiles via Home Manager (Nix flake-based)
nix run home-manager -- switch --flake . --impure

# 5. Restart shell
exec zsh
```

## Prerequisites

### Automated (Recommended)

Use bootstrap script for automated Homebrew installation:

```bash
sh ./scripts/bootstrap.sh
```

### Manual Installation

If you prefer manual installation or bootstrap script is not available:

```bash
# Install Homebrew (official method)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Note**: Homebrew's official installer requires `curl`. If `curl` is unavailable, use the bootstrap script (`scripts/bootstrap.sh`) which handles the installation process. For Nix installation, this repository uses `brew bundle` (via Brewfile) instead of the curl-based installer to maintain consistency with the package management philosophy.

## Package Management Philosophy

このプロジェクトでは **mise** を中心としたパッケージ管理を採用しています:

### 原則

- **mise 優先**: 全ての開発ツール・フォーマッター・Linter・Language Server は mise で一元管理
- **Homebrew**: システム依存関係と GUI アプリケーションのみ
- **npm/pnpm/bun グローバルは使用しない**: mise の `npm:` プレフィックスで管理

### mise で管理するもの

- 言語ランタイム（Go, Node.js, Python）
- フォーマッター・Linter（biome, prettier, stylua, shellcheck 等）
- 開発ツール（TypeScript, ESLint, esbuild 等）
- MCP サーバー（Model Context Protocol）
- CLI ツール（aws-cdk, gh, jq 等）

### Homebrew で管理するもの

- Neovim とその依存関係（lua, luajit, tree-sitter 等）
- システムレベルのライブラリ
- GUI アプリケーション（cask）

### 重複回避ルール

1. **新しいツールを追加する前**: `mise registry` で検索し、mise で管理できるか確認
2. **定期的な重複チェック**:
   - `npm -g list --depth=0` - ローカルリンク（astro-my-profile, zx-scripts）のみであること
   - `brew list --formula` - mise 管理ツールが含まれていないこと

詳細は `.claude/rules/tools/mise.md` と `.claude/rules/workflows-and-maintenance.md` を参照。

## Verification

```bash
zsh-help                # Verify zsh configuration is loaded
zsh-help tools          # Check installed tools
nvim                    # First run installs plugins
git config user.name    # Verify your name appears
mise ls                 # List all mise-managed tools
```

## Environment-Specific Setup

- **Work Environment**: Add work-specific config to `~/.gitconfig_local`
- **SSH Keys**: Generate with `ssh-keygen -t ed25519 -C "email@example.com"`
- **Terminal**: WezTerm auto-loads config, Alacritty requires restart

## Maintenance

- 定期メンテナンスとトラブルシューティングのSSTは [Workflows and Maintenance](../.claude/rules/workflows-and-maintenance.md)
- パフォーマンス測定・改善履歴・診断手順のSSTは [Performance](performance.md)
- セットアップ直後の健全性チェック:

```bash
mise run ci
```

## Troubleshooting

### bootstrap.sh実行後に "Command not found: brew"

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
- リトライ: `sh ./scripts/bootstrap.sh`
- または手動でHomebrewをインストール（前提条件セクション参照）

### Homebrewが既に存在する場合

- Bootstrapは既存インストールを検出して安全にスキップ
- 複数回実行しても問題なし

### その他のトラブルシューティング

詳細なトラブルシューティング手順は [Workflows and Maintenance](../.claude/rules/workflows-and-maintenance.md) を参照してください。
