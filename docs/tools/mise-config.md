# Mise Configuration Reference

最終更新: 2026-10-26
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)
親ドキュメント: [Mise Reference](mise.md)

## バージョン記載ルール

**ツールのバージョンは `mise/*.toml` が唯一の正本です。** このドキュメントはバージョン番号を記載せず、構成の役割とピン固定の理由のみを説明します。実際のツールリストとバージョンは該当する mise ファイルを参照してください。

## 設定ファイルの役割

### Machine ファイル (`config.<machine>.toml`)

`MISE_ENV` で選ぶ OS × 役割の機種固有設定。各環境で overlay と組み合わせて使用。

- [`config.workstation-unix.toml`](../../mise/config.workstation-unix.toml) - macOS/Linux/WSL2 の開発機
- `config.workstation-windows.toml` - Windows の開発機
- [`config.server-pi.toml`](../../mise/config.server-pi.toml) - Raspberry Pi
- [`config.ci.toml`](../../mise/config.ci.toml) - CI 環境（最小構成）

### Overlay ファイル (`config.*.toml`)

`MISE_ENV` で重ねる追加レイヤー。複数環境で共通の設定を集約。

- [`config.shared.toml`](../../mise/config.shared.toml) - default / Windows / Pi の 3 環境共通
- [`config.workstation.toml`](../../mise/config.workstation.toml) - Pi / CI 以外の開発機共通（macOS/Linux/WSL2 と Windows）

### レイヤーの適用順序

通常の開発環境（macOS/Linux/WSL2）: `MISE_ENV=macos,bun,shared,workstation,workstation-unix`（Linux/WSL2 は macos なし）で `config.macos.toml` + `config.bun.toml` + `config.shared.toml` + `config.workstation.toml` + `config.workstation-unix.toml` の additive 構成（後ろほど優先）

CI: `MISE_ENV=bun,ci` で `config.bun.toml` + `config.ci.toml`（bun 以外の overlay なし）

## ピン固定と非自明な選択の理由

### jactionlint のバージョン固定

破壊的変更があるため版を固定。更新時に attestation を確認。

構成: [`mise/config.shared.toml`](../../mise/config.shared.toml)

### uv の backend 選択

`pipx:uv` は uv 自身を uvx 経由で入れる自己参照構造になり、uv 更新時に `uv tool install uv` が停滞するため、`"github:astral-sh/uv"` を使用。全環境で統一済み。

### pnpm のメジャー固定

メジャーバージョンのみ固定。パッチ・マイナー更新は自動。

構成: [`mise/config.shared.toml`](../../mise/config.shared.toml)

### tree-sitter-cli の cargo backend

WSL で公式配布バイナリが glibc 不整合で壊れるため、cargo backend を `default-features=false` で使用（qjs/libclang 依存を回避）。

構成: [`mise/config.workstation-unix.toml`](../../mise/config.workstation-unix.toml)

### lua/luajit の Homebrew 管理

Neovim の依存関係のため、mise ではなく Homebrew で管理。

### Raspberry Pi 固有の注意

- `luacheck` は mise の tools に定義しない（registry に存在せず WARN の原因）。luarocks など mise 外で供給。
- cargo ツールセクション自体を除外（ARM 互換性考慮）。

## ツールカテゴリ

実際のツールリストは各 mise ファイルを参照：

- Language Runtimes (Python, Rust, Node.js, Go, Deno, Julia)
- Package Managers (bun, pnpm, uv, corepack)
- Formatters / Linters (biome, prettier, shellcheck, stylua, taplo, yamllint, jactionlint)
- NPM Packages (全て mise で一元管理、npm/pnpm/bun グローバルには依存しない)
- Cargo Tools (similarity-css, tree-sitter-cli, needle-cli, wrkflw, starship, bandwhich)
- CLI Tools (gh, fd, ripgrep, fzf, lazygit, bat, delta, yazi, atuin, aws-cli, kubectl, terraform, など多数)
- MCP Servers (Model Context Protocol サーバー群)
- Go Packages (wire, goimports, terraform-mcp-server)

レイヤーの選び方と Package Management Philosophy は [docs/setup.md](../setup.md#package-management-philosophy) を参照。
