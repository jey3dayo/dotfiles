---
type: reference
title: Mise Configuration Reference
description: mise の設定ファイルの役割と backend・version pin の理由
resource: docs/tools/mise-config.md
tags:
  - category/configuration
  - layer/tool
  - tool/mise
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-14
audience: developer
owner: dotfiles
---

# Mise Configuration Reference

最終更新: 2026-11-14
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

設定ファイルの役割と `MISE_ENV` の選び方は [Mise Reference](mise.md) を参照してください。ツールの version は mise 設定ファイルで管理します。この文書では pin と backend の理由を記録します。

## Configuration Files

各ファイルを読む環境の対応表は [Mise Reference](mise.md#configuration-structure) にあります。

- 環境別 entry（settings を持つ）: [`config.dev-posix.toml`](../../mise/config.dev-posix.toml)、[`config.dev-windows.toml`](../../mise/config.dev-windows.toml)、[`config.server-pi.toml`](../../mise/config.server-pi.toml)、[`config.ci.toml`](../../mise/config.ci.toml)
- 重ねる tools: [`config.interactive.toml`](../../mise/config.interactive.toml)、[`config.dev.toml`](../../mise/config.dev.toml)、[`config.bun.toml`](../../mise/config.bun.toml)
- 全環境共通 tools: [`conf.d/00-tools-all.toml`](../../mise/conf.d/00-tools-all.toml)
- repo 固有の lint / CI tools: [`.mise.toml`](../../.mise.toml)

## Pins and Backend Choices

### jactionlint

Breaking changes に備えて version を固定し、更新時に attestation を確認します。定義は [`mise/conf.d/00-tools-all.toml`](../../mise/conf.d/00-tools-all.toml) にあります。

### gh-actions-lock

`.github/workflows/actions.lock` の生成・検証用に、repo ルートの [`.mise.toml`](../../.mise.toml) で完全な version を固定します。更新先は公開から 7 日以上経過した版に限り、`mise run actions-lock:generate` で lockfile を再生成して差分を確認します。asset の実行ファイル名も同ファイルで指定します。

### uv と pnpm

- `uv` は uvx 経由の自己参照を避けるため、`github:astral-sh/uv` backend を使います。
- `pnpm` は major version を固定し、patch / minor 更新を許可します。

### tree-sitter-cli

WSL の glibc 不整合に対応するため cargo backend を使い、不要な default features を無効にします。設定は [`mise/config.dev-posix.toml`](../../mise/config.dev-posix.toml) にあります。

## Environment-specific Exceptions

- Neovim の Lua 依存は Homebrew で管理します。package ownership は [セットアップ方針](../setup.md#package-management-philosophy) を参照してください。
- Raspberry Pi では `luacheck` を mise tool として定義せず、`goimports` も `mise/config.server-pi.toml` で無効にしています。理由は同ファイルの設定コメントを参照してください。
