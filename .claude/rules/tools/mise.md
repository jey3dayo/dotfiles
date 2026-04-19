---
paths: mise/**/*, .mise.toml, scripts/setup-mise-env.sh, zsh/.zshenv, bash/.bashrc, docs/tools/mise.md
source: docs/tools/mise.md
---

# Mise Rules

Purpose: unified tool version management with mise-en-place.
Detailed Reference: [docs/tools/mise.md](../../../docs/tools/mise.md)

## Core rules

- Follow `docs/tools/mise.md` for config precedence, environment selection, and command details.
- Keep package management unified under mise where possible; do not introduce global `npm`, `pnpm`, `bun`, or `pip` installs.
- `npm:` packages use the configured pnpm backend transparently.
- For task catalogs and per-file config details, route to [docs/tools/mise-tasks.md](../../../docs/tools/mise-tasks.md) and [docs/tools/mise-config.md](../../../docs/tools/mise-config.md).

## ツール管理方針

- mise で管理: 開発ツール・フォーマッター・Linter・npm/pipx パッケージ・言語ランタイム
- Homebrew で管理: Neovim 依存関係・システムライブラリ・GUI アプリ
- `npm install -g`, `pnpm add -g`, `bun add -g`, `pip install --user` は使わない
- mise 管理ツールに `command -v` チェックを書かない（shim が自動解決）
