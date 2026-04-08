# 🚀 Setup Guide

最終更新: 2026-04-09
対象: 開発者・初心者
タグ: `category/guide`, `category/configuration`, `layer/core`, `environment/cross-platform`, `audience/beginner`

⚡ High-performance development environment setup. 本ドキュメントがセットアップ情報のSSTであり、README はリンクのみを保持します。macOS/Linux/WSL2 は Home Manager 中心、Windows は Chocolatey + mise bootstrap を扱います。

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

前提条件: Homebrew と Nix がインストール済み（上記bootstrap実行、または既にインストール済み）

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

## Windows Bootstrap

Windows は `Chocolatey = bootstrap`、`mise = 開発ツール` の分離を前提にセットアップします。

```powershell
git clone https://github.com/jey3dayo/dotfiles $HOME\.config
cd $HOME\.config
powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1
```

### 実行内容

- Chocolatey 本体を導入（未導入の場合のみ）
- `windows/chocolatey/packages.config` から bootstrap/GUI パッケージを一括導入
- `MISE_CONFIG_FILE` を `mise/config.windows.toml` に向けて `mise install` を実行
- `~/.config/powershell` を正本にし、`Documents/PowerShell` と `Documents/WindowsPowerShell` のエントリポイントを再生成

### Windows bootstrap の対象

- Chocolatey: `git`, `mise`, `wezterm`, `neovim`, `7zip`, `googlechrome`, `vscode`
- mise: `mise/config.windows.toml` に定義した CLI・runtime・formatter・MCP 関連

PowerShell から現在の Chocolatey パッケージ一覧を manifest 化したい場合は次を使います。

```powershell
choco export .\windows\chocolatey\packages.config
```

PowerShell プロファイルの入口だけを作り直したい場合は次を使います。

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1 -ProfilesOnly
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

Note: Homebrew's official installer requires `curl`. If `curl` is unavailable, use the bootstrap script (`scripts/bootstrap.sh`) which handles the installation process. For Nix installation, this repository uses `brew bundle` (via Brewfile) instead of the curl-based installer to maintain consistency with the package management philosophy.

## Package Management Philosophy

このプロジェクトでは **mise** を中心としたパッケージ管理を採用しています:

### 原則

- mise 優先: 全ての開発ツール・フォーマッター・Linter・Language Server は mise で一元管理
- Homebrew: システム依存関係と GUI アプリケーションのみ
- Chocolatey (Windows): bootstrap パッケージと GUI アプリケーションのみ
- npm/pnpm/bun グローバルは使用しない: mise の `npm:` プレフィックスで管理

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

### Chocolatey で管理するもの（Windows bootstrap）

- `mise` 自体の導入
- Git や WezTerm などのベースアプリ
- GUI アプリケーション（Chrome, VS Code 等）
- `neovim` バイナリのようなアプリ本体
- 理由: 初回マシンセットアップの bootstrap を単純化し、CLI ツール本体は `mise install` に集約するため

### 重複回避ルール

1. 新しいツールを追加する前: `mise registry` で検索し、mise で管理できるか確認
2. 定期的な重複チェック:
   - `npm -g list --depth=0` - ローカルリンク（astro-my-profile, zx-scripts）のみであること
   - `brew list --formula` - mise 管理ツールが含まれていないこと
   - `windows/chocolatey/packages.config` - `mise/config.windows.toml` にある CLI/runtime を重複追加しないこと

詳細は [docs/tools/mise.md](tools/mise.md) と [docs/tools/workflows.md](tools/workflows.md) を参照してください。

## Verification

```bash
zsh-help                # Verify zsh configuration is loaded
zsh-help tools          # Check installed tools
nvim                    # First run installs plugins
git config user.name    # Verify your name appears
mise ls                 # List all mise-managed tools
```

## Environment-Specific Setup

- Work Environment: Add work-specific config to `~/.gitconfig_local`
- SSH Keys: Generate with `ssh-keygen -t ed25519 -C "email@example.com"`
- Terminal: WezTerm auto-loads config, Alacritty requires restart
- `dotenvx` / `.env.keys` / 1Password service account の運用は [docs/tools/1password.md](tools/1password.md) を参照

## Maintenance

- 定期メンテナンスとトラブルシューティングのSSTは [Workflows and Maintenance](tools/workflows.md)
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

詳細なトラブルシューティング手順は [Workflows and Maintenance](tools/workflows.md) を参照してください。
