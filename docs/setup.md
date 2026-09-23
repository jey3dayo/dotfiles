# 🚀 Setup Guide

最終更新: 2026-09-23
対象: 開発者・初心者
タグ: `category/guide`, `category/configuration`, `layer/core`, `environment/cross-platform`, `audience/beginner`

⚡ High-performance development environment setup. 本ドキュメントがセットアップ情報のSSTであり、README はリンクのみを保持します。macOS/Linux/WSL2 は mise bootstrap 中心（dotfiles 配布・launchd agents・ツール導入）、Windows は Chocolatey + mise bootstrap を扱います。Home Manager / Nix flake は撤去済みです。

## セットアップの全体像

セットアップの本体は **`mise bootstrap`** です。1コマンドでマシン全体を宣言的に収束させます:

1. `[bootstrap.packages]` — brew パッケージ（btop 等）
2. `[dotfiles]` — HOME 側エントリポイントの symlink / copy 配布
3. `[bootstrap.macos.launchd.agents]` — LaunchAgents（GUI env 注入）
4. `[tools]` — 全開発ツール（言語 runtime / CLI / formatter / MCP）

`scripts/bootstrap.sh` は fresh macOS で **Homebrew を導入するだけの前準備**です。mise 本体は macOS / Linux / WSL2 では公式インストーラ（`curl https://mise.run | sh` → `~/.local/bin/mise`）、Windows では Chocolatey（`windows/chocolatey/packages.config`）で入れ、更新は `mise self-update` を使う。Homebrew formula は adhoc 署名かつバージョン付きパスのため、macOS Tahoe 以降の TCC（「他のアプリからのデータ」等）許可が更新のたびに無効化され再プロンプトされる。公式バイナリは Developer ID 署名で許可が持続する。claude（Claude Code）と codex（Codex CLI）も同じ理由で mise `[tools]` には置かず、`mise bootstrap` の `[bootstrap.hooks.post-tools]` hook が未導入時のみ公式インストーラで導入する。更新は `claude update` / `codex update` に任せる。
Homebrew 導入済みのマシンでは実行不要で、Quick Setup の手順 4 から始められます。

`pam-reattach` は `[bootstrap.packages]` で宣言されている。`/etc/pam.d/sudo_local` の `auth optional /opt/homebrew/lib/pam/pam_reattach.so` 行はこのリポジトリでは管理せず、手動設定する。

---

## Quick Setup

前提条件: Homebrew がインストール済み（上記bootstrap実行、または既にインストール済み）

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

# 3. Install Homebrew packages
brew bundle

# 4. Converge the machine via mise bootstrap
#    (dotfiles symlink, macOS LaunchAgents, tools)
#    初回は ~/.zshenv 未配布のため MISE_CONFIG_FILE / MISE_ENV を明示する（次回以降は不要）
export MISE_CONFIG_FILE="$HOME/.config/mise/entry.workstation-unix.toml"
export MISE_ENV=macos,shared,workstation # macOS / shared / workstation overlay を読み込む（既存の MISE_ENV は通常の shell setup が保持して追加）
mise trust && mise bootstrap --yes

# 5. Restart shell
exec zsh
```

状態確認は `mise bootstrap status` / `mise dotfiles status`、差分プレビューは `mise bootstrap --dry-run` を使います。
dotfiles / launchd の定義は `mise/config.toml`（OS 非依存、常時ロード）、3 OS 共通 tools は `mise/config.shared.toml`（`MISE_ENV` に `shared` が含まれる場合だけロード）、default / Windows 共通 tools は `mise/config.workstation.toml`（`MISE_ENV` に `workstation` が含まれる場合だけロード）、OS 別 tools は `mise/entry.workstation-unix.toml` / `mise/entry.server-pi.toml`（`MISE_CONFIG_FILE` 経由）、macOS 専用の brew packages・LaunchAgents・dotfiles は `mise/config.macos.toml`（`MISE_ENV` に `macos` が含まれる場合）にあります。
Raspberry Pi は `entry.server-pi.toml` + shared overlay を使い、`hadolint` など ARM/minimal 構成で意図的に除外したツールを追加しません。CI は `entry.ci.toml` だけを使い、default / shared / workstation overlay を読み込みません。Linux/WSL2 は Homebrew の代わりに各ディストリのパッケージマネージャーを使います（`brew bundle` は macOS 専用）。

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
- `MISE_CONFIG_FILE` を `mise/entry.workstation-windows.toml` に向け、`MISE_ENV` に `shared,workstation` を追加して `mise install` を実行
- `windows/setup.ps1` は `mise install` 後、claude / codex が未導入の場合のみ公式インストーラで導入する（既導入の場合は更新しない）
- `~/.config/powershell` を正本にし、`Documents/PowerShell` と `Documents/WindowsPowerShell` のエントリポイントを再生成

### Windows bootstrap の対象

- Chocolatey: `git`, `mise`, `wezterm`, `neovim`, `7zip`, `googlechrome`, `vscode`
- mise: `mise/entry.workstation-windows.toml` + `mise/config.shared.toml` に定義した CLI・runtime・formatter・MCP 関連

PowerShell から現在の Chocolatey パッケージ一覧を manifest 化したい場合は次を使います。

```powershell
choco export .\windows\chocolatey\packages.config
```

PowerShell プロファイルの入口だけを作り直したい場合は次を使います。

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1 -ProfilesOnly
```

## Prerequisites

### Homebrew（macOS の前準備）

fresh macOS のみ、`scripts/bootstrap.sh` で Homebrew を自動導入する（既に導入済みなら不要）:

```bash
sh ./scripts/bootstrap.sh
```

実行内容: Homebrew インストール（未導入時のみ）、アーキテクチャ検出、前提条件検証（git/zsh/curl）、現セッションへの `brew` PATH 設定。Linux/WSL2 では使わない。

### Linux/WSL2（各ディストリのパッケージマネージャー）

`git` / `zsh` / `curl` を先に導入する:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git zsh curl

# Fedora
sudo dnf install -y git zsh curl

# Arch
sudo pacman -S --noconfirm git zsh curl
```

### Manual Installation

If you prefer manual installation or bootstrap script is not available:

```bash
# Install Homebrew (official method)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Note: Homebrew's official installer requires `curl`. If `curl` is unavailable, use the bootstrap script (`scripts/bootstrap.sh`) which handles the installation process.

## Package Management Philosophy

このプロジェクトはツール導入を 4 層 + Windows Chocolatey に分離する。**どの層で管理するかはここが唯一の方針本文**（他の docs / rules は本節への pointer に留める）。

### 4 層

1. mise `[tools]`: CLI・言語ランタイム・開発ツール・`go:` / `cargo:` / `npm:` / `pipx:` プレフィックス付きパッケージ。`mise/config.shared.toml`（全 OS）、`mise/config.workstation.toml`（default / Windows）、`mise/entry.*.toml`（環境別）で宣言する。npm/pnpm/bun グローバルは使わない。
2. mise bootstrap `[bootstrap.packages]`: macOS の Homebrew formula。システムライブラリ・native バイナリ（Neovim とその依存関係、btop, cmake, podman, powershell, rust-analyzer 等、mise でも入れられるものを含む）。`mise/config.macos.toml` に `"brew:<name>" = "latest"` で宣言する。
3. Brewfile: cask・MAS app・VS Code 拡張、および `[bootstrap.packages]` で表現できない formula の例外リスト（install args・`restart_service`・private または metadata なし tap）。
4. 自己更新 standalone: `mise` / `claude` / `codex`。公式インストーラで入れ（mise は macOS / Linux / WSL2 で `curl https://mise.run | sh`、Windows では Chocolatey）、`claude` / `codex` は `[bootstrap.hooks.post-tools]` → `mise/lib/ensure-standalone.sh`（Windows: `windows/setup.ps1` の `Ensure-StandaloneCli`）が未導入時のみ導入する。更新は各ツールの自己更新（`mise self-update` / `claude update` / `codex update`）に任せ、mise `[tools]` には置かない（二重の更新経路を避けるため）。

### Chocolatey（Windows bootstrap）

- `mise` 自体の導入、Git や WezTerm などのベースアプリ、GUI アプリケーション（Chrome, VS Code 等）、`neovim` バイナリのようなアプリ本体
- 理由: 初回マシンセットアップの bootstrap を単純化し、CLI ツール本体は `mise install` に集約するため

### レイヤーの選び方

1. GUI app、MAS app、VS Code 拡張 → Brewfile
2. 自前のインストーラと自己更新コマンドを持ち最新版を追随すべき → 自己更新 standalone
3. mise（registry またはパッケージバックエンド）経由で入る cross-platform CLI → `[tools]`
4. システムライブラリまたは macOS native バイナリ → `[bootstrap.packages]`。表現できない場合のみ Brewfile へ `brew` 行を追加する（install args・service restart・API メタデータの無い tap）

ランタイムは mise を通す。Homebrew 版ランタイムを残すのは、あるフォーミュラがそれに依存する場合だけ（`brew uses --installed <name>`）。1 ツールは 1 層でのみ宣言する（2 層に置くと更新経路が二重になる）。`brew:neovim`（エディタ）と `npm:neovim`（Node クライアント）は別パッケージなので重複ではない。

### 重複回避ルール

1. 新しいツールを追加する前: `mise registry` で検索し、mise で管理できるか確認
2. 定期的な重複チェック:
   - `npm -g list --depth=0` - ローカルリンク（astro-my-profile, zx-scripts）のみであること
   - `brew list --formula` - mise 管理ツールが含まれていないこと
   - `windows/chocolatey/packages.config` - `mise/entry.workstation-windows.toml` にある CLI/runtime を重複追加しないこと

詳細は [docs/tools/mise.md](tools/mise.md) と [docs/tools/workflows.md](tools/workflows.md) を参照してください。

## Verification

```bash
zsh-benchmark            # Measures startup time; failure/error means zsh config didn't load
nvim                    # First run installs plugins
git config user.name    # Verify your name appears
mise ls                 # List all mise-managed tools
```

## Atuin (シェル履歴のマシン間同期)

`atuin` は mise 経由で Mac/Linux/WSL2 に導入され、`Ctrl+R` で SQLite ベースの履歴 TUI を開きます。ローカルだけで使う場合は追加作業不要。複数マシンで履歴を E2E 暗号化同期する場合のみ以下を実施します。

### 初回マシン (登録 + 鍵バックアップ)

```bash
atuin register -u <username> -e <email>   # 公式 sync server (api.atuin.sh) に登録
atuin key                                  # 暗号化キーを表示
# 上記キーを 1Password 等のパスワードマネージャに保存 (必須)
atuin import zsh                           # 既存 ~/.zsh_history を取り込み (任意)
atuin sync -f                              # 初回フル同期
```

> ⚠️ 暗号化キーは E2E 暗号化の復号鍵そのもの。失うとパスワードリセットしても他マシンから履歴を復号できなくなります。`~/.local/share/atuin/key` のみに頼らず必ずパスマネにも保管。

### 2 台目以降のマシン

```bash
mise install                               # atuin バイナリ取得
exec zsh -l                                # 新シェル起動
atuin login -u <username> -k <暗号化キー>   # パスワードはプロンプトで入力
atuin sync                                 # サーバから履歴を pull
```

### 状態確認

```bash
atuin status   # Last sync / Username / Sync frequency を表示
```

デフォルト同期間隔は 5 分。変更する場合は `~/.config/atuin/config.toml` で `sync_frequency = "10m"` などを指定。

## Environment-Specific Setup

- Work Environment: Add work-specific config to `~/.gitconfig_local`
- SSH Keys: Generate with `ssh-keygen -t ed25519 -C "email@example.com"`
- Terminal: WezTerm auto-loads config, Alacritty requires restart
- `dotenvx` / `.env.keys` / 1Password service account の運用は [docs/tools/1password.md](tools/1password.md) を参照

## Maintenance

- 定期メンテナンスとトラブルシューティングのSSTは [Workflows and Maintenance](tools/workflows.md)
- 起動時間の実測値は [Zsh](tools/zsh.md#検証) / [Neovim](tools/nvim.md#検証) の検証節を参照
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
