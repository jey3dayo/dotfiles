---
paths: docs/maintenance.md, docs/performance.md, .github/workflows/**/*.yml, .github/PULL_REQUEST_TEMPLATE.md, .claude/commands/**/*.sh, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json
---

# Workflows and Maintenance

Purpose: keep recurring operations and troubleshooting guardrails concise. Scope: maintenance cadences, Brewfile management, and where to log performance findings.
Sources: docs/maintenance.md.

## Cadence

- Weekly: `brew update && brew upgrade` + `mise upgrade`; refresh plugins (`sheldon update`, `nvim --headless -c 'lua require("lazy").sync()' -c q`, tmux plugin updater).
- Monthly: run zsh benchmarks and review config for unused items; clean logs; record metrics in docs/performance.md; `mise prune` to remove unused versions.
- Quarterly: full settings audit, dependency pruning, and backup verification.

## Troubleshooting routing

- Performance regressions: follow docs/performance.md troubleshooting; log measurements there.
- Zsh recovery: `rm -rf ~/.zcompdump*` then `exec zsh`; use `zsh -df` for minimal startup.
- LSP issues: `:LspInfo`, `:Mason`, check `~/.local/share/nvim/lsp.log`; reinstall servers if needed.
- Git auth: `ssh -T git@github.com`, confirm 1Password CLI and SSH agent status.

## Debug commands

- Env checks: `env | grep -E "(SHELL|TERM|PATH|CONFIG)"`, `which`, `type`.
- Logs: `tail -f ~/.local/share/nvim/lsp.log`, `tail -f ~/.config/zsh/performance.log`.
- Process watch: `top -pid $(pgrep zsh)`, `ps aux | grep -E "(zsh|nvim|tmux)"`.

## Automation and scripts

- Maintenance script pattern: log zsh startup time, update plugins, clear temporary files, back up key configs (see sample in docs/maintenance.md).
- Keep backups under ~/.config/zsh/backup with dated filenames.

## Tool Management Philosophy

### mise 優先原則

#### 原則

開発ツール・フォーマッター・Linter は mise で統一管理。Homebrew はシステム依存関係と GUI アプリのみ。

#### mise で管理

- 全ての開発ツール（フォーマッター、Linter、CLI ツール）
- 全ての npm/pipx パッケージ
- 開発用の言語ランタイム（Node.js, Python, Go）

#### Homebrew で管理

- Neovim とその依存関係（lua, luajit, luarocks, libuv 等）
- システムレベルのライブラリ
- GUI アプリケーション（cask）
- システムツール用の言語ランタイム（必要な場合のみ）

#### ハイブリッド運用

- Node.js: Homebrew 版（システム依存関係用） + mise 版（開発用）
- Python: Homebrew 版（システムツール用） + mise 版（開発用）

#### 理由

Single Source of Truth、バージョン固定、プロジェクト別オーバーライド、再現性

### Brewfile management

- Maintain 20-section layout (taps, core libs, build tools, dev tools, languages, shell/terminal, CLI, monitoring, devops/cloud, databases, security/network, package mgmt, documentation, lang build tools, specialized, casks, fonts, MAS, VSCode, Go packages).
- **重要**: フォーマッター・Linter・CLI ツールは mise で管理するため、Brewfile には追加しない（biome, prettier, stylua, shfmt, shellcheck, yamllint, taplo, hadolint, fd, jq, gh 等）
- Special cases: `node` link:false (managed by mise), `mysql` restart_service:changed, `utf8proc` args:["HEAD"], `postgresql@14` pinned.
- Workflow for adding packages:
  1. **まず mise で管理できるか確認** (`mise registry` で検索)
  2. システム依存関係または GUI アプリの場合のみ Homebrew に追加
  3. Install, `brew bundle dump --force --file=/tmp/brewfile-new.txt`, diff against Brewfile
  4. Insert alphabetically within the right section
  5. Run `brew bundle check` and `brew bundle install --no-upgrade` to validate
- Monthly regeneration: backup current, dump to temp, review diffs, run checks, and test install with `--no-upgrade --verbose`.
- **重複チェック**: 定期的に以下のコマンドで mise で管理しているパッケージが他のパッケージマネージャーに残っていないか確認
  - `npm -g list --depth=0` - npm グローバルはローカルリンク（astro-my-profile, zx-scripts）のみであること
  - `bun pm ls -g` または `ls ~/.bun/install/global/node_modules/.bin` - bun グローバルは空であること

### mise management

- Primary config: `mise/config.toml` (6 カテゴリ構造: Runtimes, Package Managers, Formatters/Linters, NPM, Cargo, CLI Tools)
- Weekly updates: `mise upgrade` to update all tools
- Monthly cleanup: `mise prune` to remove unused versions
- Verification: `mise doctor` for health check, `mise ls` for installed tools
- **重複回避**: 新しいツールを追加する前に `brew list` で Homebrew に同じツールがないか確認
- **npm パッケージの完全移行完了**: 全ての開発ツール・MCP サーバー・Language Server は mise で一元管理（npm/pnpm/bun グローバルには依存しない）

## Backups and recovery

- For Brewfile changes, keep dated backups before large edits.
- Emergency shell recovery: `zsh --no-rcs` to bypass config; reinstall dependencies via `brew bundle --force` and `mise install ...` when required.
