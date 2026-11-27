---
type: guide
title: Setup Guide
description: dotfiles の導入、環境別セットアップ、ツール管理方針
resource: docs/setup.md
tags:
  - category/guide
  - category/configuration
  - layer/core
  - environment/cross-platform
  - audience/beginner
timestamp: 2026-11-27
audience: beginner
owner: dotfiles
---

# Setup Guide

本ドキュメントは、macOS / Linux / WSL2 / Windows 向け開発環境のセットアップ手順とツール管理方針の正本です（`README.md` はリンクのみを保持します）。macOS / Linux / WSL2 は `mise bootstrap` を中心に構成し、Windows は Chocolatey と `mise` を組み合わせて管理します。Home Manager / Nix flake は撤去済みです。

## セットアップの全体像

セットアップの本体は **`mise bootstrap`** です。1 コマンドでマシン全体を宣言的に収束させます。

1. `[bootstrap.packages]` — Homebrew パッケージ（`btop` など）
2. `[dotfiles]` — `$HOME` 側エントリポイントの symlink / copy 配布
3. `[bootstrap.macos.launchd.agents]` — LaunchAgents（GUI 環境変数の注入）
4. `[tools]` — 全開発ツール（言語ランタイム / CLI / formatter / MCP）

### 前準備と自己更新ツールの扱い

- Homebrew の前準備: `scripts/bootstrap.sh` は、fresh macOS で Homebrew を導入するためだけのスクリプトです。Homebrew 導入済みのマシンでは実行不要です。
- `mise` 本体の導入と更新: macOS / Linux / WSL2 では公式インストーラ（`curl https://mise.run | sh` → `~/.local/bin/mise`）、Windows では Chocolatey（`windows/chocolatey/packages.config`）で導入し、更新は `mise self-update` を使います。Homebrew formula は adhoc 署名かつバージョン付きパスのため、macOS Tahoe 以降の TCC（「他のアプリからのデータ」など）の許可が更新のたびに無効化されて再プロンプトされます。公式バイナリは Developer ID 署名のため許可が持続します。
- `claude` / `codex` の導入と更新: 同じ理由から `mise` の `[tools]` には置かず、`mise bootstrap` の `[bootstrap.hooks.post-tools]` hook で未導入時のみ公式インストーラから導入します。更新は `claude update` / `codex update` に任せます。
- `pam-reattach`: `[bootstrap.packages]` で宣言しています。`/etc/pam.d/sudo_local` の `auth optional /opt/homebrew/lib/pam/pam_reattach.so` 行はこのリポジトリでは管理せず、手動で設定します。

## Quick Setup

前提条件として、Homebrew がインストール済みであること（新規 macOS の場合は後述の `scripts/bootstrap.sh` を先に実行します）。

```bash
# 1. リポジトリをクローン
git clone https://github.com/jey3dayo/dotfiles ~/.config
cd ~/.config

# 2. Git のローカルユーザー設定を作成（必須）
cat > ~/.gitconfig_local << EOF
[user]
    name = Your Name
    email = your.email@example.com
EOF

# 3. Homebrew パッケージを導入（macOS のみ）
brew bundle

# 4. mise bootstrap でマシン全体を収束
#    （dotfiles symlink、macOS LaunchAgents、各種ツール）
#    初回は ~/.zshenv 未配布のため MISE_CONFIG_DIR / MISE_ENV を明示します（次回以降は不要）
export MISE_CONFIG_DIR="$HOME/.config/mise"
export MISE_ENV=macos,bun,interactive,dev,dev-posix
mise trust && mise bootstrap --yes

# 5. シェルを再起動
exec zsh
```

- 状態確認は `mise bootstrap status` / `mise dotfiles status`、差分プレビューは `mise bootstrap --dry-run` を使います。
- OS 非依存の dotfiles / 共通設定は `mise/config.toml`（常時ロード）、macOS 専用の brew パッケージ・LaunchAgents・dotfiles は `mise/config.macos.toml` に定義しています。各ツールの配置先と環境別の読み込み対応表は [Mise Reference](tools/mise.md#configuration-structure) を参照してください。
- すべての設定は `MISE_CONFIG_DIR` で指定したディレクトリから、`MISE_ENV` の値に応じて読み込まれます。
  - Raspberry Pi: `MISE_ENV=interactive,server-pi` を使用し、`hadolint` など ARM / minimal 構成で意図的に除外したツールを追加しません。
  - CI: `MISE_ENV=bun,ci` を使用し、`interactive` / `dev` を読み込みません。
  - Linux / WSL2: `brew bundle` は macOS 専用のため使わず、各ディストリのパッケージマネージャーを利用します。

### macOS: ai-usage-snapshot の前提（private repo の手動 clone）

LaunchAgent `ai-usage-snapshot`（平日 9:50 / 14:50 に codexbar の使用量を export）は、private repo `jey3dayo/ai-usage-log` の `snapshot.sh` を実行します。本リポジトリは public のため、`mise bootstrap` では自動配置しません。利用する Mac では `gh auth login` 済みの状態で一度だけ手動 clone してください。

```bash
gh repo clone jey3dayo/ai-usage-log ~/.local/share/ai-usage-log
```

- 未 clone の場合、ジョブは毎回 exit 1 となり、`~/Library/Logs/ai-usage-snapshot.log` に `ai-usage-snapshot: ... not found; run: gh repo clone ...` を出力します。使わない Mac では無視して問題ありません。
- clone 済みで `snapshot.sh` が欠損している場合や実行権限がない場合も exit 1 となり、ログに復旧手順（`git -C ~/.local/share/ai-usage-log checkout -- snapshot.sh` または再 clone、`chmod +x`）を出力します。

### macOS: Spotlight の検索対象から `~/src` と `~/tmp` を外す（手動）

ビルド成果物や `node_modules` など大量のファイルが増えるたびに Spotlight の再インデックスが走り、負荷がかかります（Claude Code で大量のファイルを扱う作業で効きます）。新しい Mac では一度だけ手動で除外してください。

1. システム設定 → Spotlight →「検索のプライバシー」を開きます。
2. `+` から `~/src` と `~/tmp` を追加します。

- `~/.t3` は隠しフォルダのため、もともとインデックス対象外です。
- git submodule と worktree は `~/src` 配下にあるため、`~/src` の除外でまとめて外れます。
- 除外リストは macOS の保護領域にあり、`mise` やスクリプトでは書き換えられません。フォルダに置く `.metadata_never_index` も現行の macOS では効きません。
- 確認: `mdfind -onlyin ~/src -count 'kMDItemFSName == "package.json"'` の結果が `0` になれば除外できています。

## Windows Bootstrap

Windows では「Chocolatey = bootstrap」「`mise` = 開発ツール」の役割分離を前提にセットアップします。

```powershell
git clone https://github.com/jey3dayo/dotfiles $HOME\.config
cd $HOME\.config
powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1
```

### 実行内容

- Chocolatey 本体を導入します（未導入の場合のみ）。
- `windows/chocolatey/packages.config` から bootstrap / GUI パッケージを一括導入します。
- `MISE_CONFIG_DIR` を `~/.config/mise` に向け、`MISE_ENV=bun,interactive,dev,dev-windows` で `mise install` を実行します。
- `mise install` 後、`claude` / `codex` が未導入の場合のみ公式インストーラで導入します（既導入の場合は更新しません）。
- `~/.config/powershell` を正本とし、`Documents/PowerShell` と `Documents/WindowsPowerShell` のエントリポイントを再生成します。

### Windows bootstrap の対象

- Chocolatey: `git`, `mise`, `wezterm`, `neovim`, `7zip`, `googlechrome`, `vscode`
- mise: `MISE_ENV=bun,interactive,dev,dev-windows` で読み込む設定（`conf.d/00-tools-all.toml`、`config.bun.toml`、`config.interactive.toml`、`config.dev.toml`、`config.dev-windows.toml`）に定義した CLI・ランタイム・formatter・MCP 関連

現在の Chocolatey パッケージ一覧を manifest として書き出す場合は次を実行します。

```powershell
choco export .\windows\chocolatey\packages.config
```

PowerShell プロファイルの入口だけを作り直す場合は次を実行します。

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1 -ProfilesOnly
```

## Prerequisites

### Homebrew（macOS の前準備）

fresh macOS のみ、`scripts/bootstrap.sh` で Homebrew を自動導入します（既に導入済みなら不要です）。

```bash
sh ./scripts/bootstrap.sh
```

このスクリプトは、Homebrew のインストール（未導入時のみ）、アーキテクチャ検出、前提コマンド（`git` / `zsh` / `curl`）の確認、現在セッションへの `brew` PATH 設定を行います。Linux / WSL2 では使用しません。

### Linux / WSL2（各ディストリのパッケージマネージャー）

先に `git` / `zsh` / `curl` を導入します。

```bash
# Ubuntu / Debian
sudo apt update && sudo apt install -y git zsh curl

# Fedora
sudo dnf install -y git zsh curl

# Arch
sudo pacman -S --noconfirm git zsh curl
```

### 手動インストール

手動で Homebrew を導入したい場合や `scripts/bootstrap.sh` が使えない場合は、公式インストーラを実行します。

```bash
# Homebrew 公式インストーラ
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> **注意**: Homebrew の公式インストーラと `scripts/bootstrap.sh` はどちらも `curl` を必要とします。未導入の場合は、先に OS のパッケージマネージャーで `curl` をインストールしてください。

## Package Management Philosophy

このプロジェクトでは、ツール導入を「4 層 + Windows Chocolatey」に分離します。**どの層でツールを管理するかの方針は本節が唯一の正本**であり、他の docs や rules は本節への参照に留めます。

### 4 層

1. mise `[tools]`: CLI・言語ランタイム・開発ツール・`go:` / `cargo:` / `npm:` / `pipx:` プレフィックス付きパッケージを管理します。`mise/conf.d/00-tools-all.toml`（全環境共通）、`mise/config.bun.toml`（bun）、`mise/config.interactive.toml`（CI 以外）、`mise/config.dev.toml`（開発機）、`mise/config.<machine>.toml`（機種別）で宣言します。このリポジトリ自身の lint / CI だけが使うツール（例: `gh-actions-lock`）はリポジトリルートの `.mise.toml` に置きます。npm / pnpm / bun のグローバルインストールは使いません。
2. mise bootstrap `[bootstrap.packages]`: macOS の Homebrew formula を管理します。システムライブラリや native バイナリ（Neovim とその依存関係、`btop`, `cmake`, `podman`, `powershell`, `rust-analyzer` など、`mise` でも入れられるものを含む）を、`mise/config.macos.toml` に `"brew:<name>" = "latest"` で宣言します。
3. Brewfile: cask・MAS app・VS Code 拡張、および `[bootstrap.packages]` で表現できない formula の例外リスト（install args・`restart_service`・private または metadata なし tap）を管理します。
4. 自己更新 standalone: `mise` 本体と自己更新機能を持つ CLI を管理します。`mise` は公式インストーラ（macOS / Linux / WSL2 は `curl https://mise.run | sh`、Windows は Chocolatey）で導入し、対象 CLI は `[bootstrap.hooks.post-tools]` → `mise/lib/ensure-standalone.sh`（Windows は `windows/setup.ps1` の `Ensure-StandaloneCli`）が未導入時のみ導入します。更新は各ツールの自己更新（`mise self-update`、CLI は `mise run update:standalone`）に任せ、二重の更新経路を避けるため `mise` `[tools]` には置きません。対象 CLI の一覧は文書に列挙せず、導入側スクリプトと `update:standalone` タスクの定義を正本とします。

### Chocolatey（Windows bootstrap）

- 対象: `mise` 本体、Git や WezTerm などのベースアプリ、GUI アプリケーション（Chrome, VS Code など）、`neovim` バイナリなどのアプリ本体
- 理由: 初回セットアップの bootstrap を単純化し、CLI ツール本体は `mise install` に集約するため

### レイヤーの選び方

1. GUI app・MAS app・VS Code 拡張 → **Brewfile**
2. 自前のインストーラと自己更新コマンドを持ち、最新版を追随すべきツール → **自己更新 standalone**
3. `mise`（registry またはパッケージバックエンド）経由で入る cross-platform CLI → **`[tools]`**
4. システムライブラリまたは macOS native バイナリ → **`[bootstrap.packages]`**（install args・service restart・API メタデータのない tap など、表現できない場合のみ Brewfile へ `brew` 行を追加します）

ランタイムは `mise` を通して管理します。Homebrew 版ランタイムを残すのは、他の formula がそれに依存している場合だけです（`brew uses --installed <name>` で確認できます）。更新経路の二重化を防ぐため、1 つのツールは 1 層でのみ宣言します。なお、`brew:neovim`（エディタ本体）と `npm:neovim`（Node クライアント）は別パッケージのため重複には当たりません。

### 重複回避ルール

1. 新しいツールを追加する前に `mise registry` で検索し、`mise` で管理できるか確認します。
2. 以下のコマンドで定期的に重複を確認します。
   - `npm -g list --depth=0` — ローカルリンク（`astro-my-profile`, `zx-scripts`）のみであること
   - `brew list --formula` — `mise` 管理ツールが含まれていないこと
   - `windows/chocolatey/packages.config` — `mise/config.dev-windows.toml` にある CLI / ランタイムを重複追加していないこと

詳細は [Mise Reference](tools/mise.md) と [Workflows & Maintenance](tools/workflows.md) を参照してください。

## Verification

セットアップ後は以下で動作を確認します。

```bash
zsh-benchmark            # Zsh の起動時間を計測（エラーが出る場合は設定の読み込みに問題あり）
nvim                     # 初回起動時にプラグインを導入
git config user.name     # ~/.gitconfig_local のユーザー名が表示されることを確認
mise ls                  # mise 管理ツールの一覧を確認
```

## Atuin（シェル履歴のマシン間同期）

`atuin` は `mise` 経由で macOS / Linux / WSL2 に導入され、`Ctrl+R` で SQLite ベースの履歴 TUI を開きます。ローカル利用のみであれば追加設定は不要です。複数マシン間で履歴を E2E 暗号化同期する場合のみ、以下の手順を実施します。

### 初回マシン（登録 + 鍵バックアップ）

```bash
atuin register -u <username> -e <email>   # 公式 sync server (api.atuin.sh) に登録
atuin key                                  # 暗号化キーを表示
# 表示されたキーを 1Password などのパスワードマネージャに保存します（必須）
atuin import zsh                           # 既存の ~/.zsh_history を取り込み（任意）
atuin sync -f                              # 初回フル同期
```

> **注意**: 暗号化キーは E2E 暗号化の復号鍵そのものです。紛失するとパスワードをリセットしても他マシンから履歴を復号できなくなります。`~/.local/share/atuin/key` のみに頼らず、必ずパスワードマネージャにも保管してください。

### 2 台目以降のマシン

```bash
mise install                               # atuin バイナリを取得
exec zsh -l                                # 新しいシェルを起動
atuin login -u <username> -k <暗号化キー>   # パスワードはプロンプトで入力
atuin sync                                 # サーバから履歴を pull
```

### 状態確認

```bash
atuin status   # Last sync / Username / Sync frequency を表示
```

既定の同期間隔は 5 分です。変更する場合は `~/.config/atuin/config.toml` で `sync_frequency = "10m"` のように指定します。

## 環境別の追加設定

- 仕事用環境: 職場固有の Git 設定は `~/.gitconfig_local` に記述します。
- SSH 鍵: `ssh-keygen -t ed25519 -C "email@example.com"` で生成します。
- ターミナル: WezTerm は設定を自動再読み込みしますが、Alacritty は再起動が必要です。
- 秘密情報・環境変数: `dotenvx` / `.env.keys` / 1Password service account の運用は [1Password CLI](tools/1password.md) を参照してください。

## Maintenance

- 定期メンテナンスとトラブルシューティングの正本は [Workflows & Maintenance](tools/workflows.md) です。
- 起動時間の実測値は [Zsh](tools/zsh.md#検証) と [Neovim](tools/nvim.md#検証) の検証節を参照してください。
- セットアップ直後の健全性チェックは次を実行します。

```bash
mise run ci
```

## Troubleshooting

### `bootstrap.sh` 実行後に "Command not found: brew" と表示される

現在のシェルに Homebrew の PATH を追加します。

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"
```

その後、`exec zsh` でシェルを再起動すると永続的に有効になります。

### Bootstrap がネットワークエラーで失敗する

- インターネット接続を確認します。
- `sh ./scripts/bootstrap.sh` を再実行します。
- 解決しない場合は「手動インストール」の手順で Homebrew を直接導入します。

### Homebrew が既に存在する場合

- `scripts/bootstrap.sh` は既存インストールを検出して安全にスキップするため、複数回実行しても問題ありません。

### その他のトラブルシューティング

詳細なトラブルシューティング手順は [Workflows & Maintenance](tools/workflows.md) を参照してください。
