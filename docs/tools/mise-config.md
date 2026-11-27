---
type: reference
title: Mise Configuration Reference
description: mise の設定ファイルの役割と backend 選定・バージョン固定の理由
resource: docs/tools/mise-config.md
tags:
  - category/configuration
  - layer/tool
  - tool/mise
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Mise Configuration Reference

設定ファイルの役割と `MISE_ENV` の選び方は [Mise Reference](mise.md) を参照してください。ツールのバージョンは各 mise 設定ファイルで管理します。この文書では、バージョン固定と backend 選定の理由を記録します。

## Configuration Files

各ファイルを読み込む環境の対応表は [Mise Reference](mise.md#configuration-structure) にあります。

- 環境別のエントリ設定（settings を持つ）: [`config.dev-posix.toml`](../../mise/config.dev-posix.toml)、[`config.dev-windows.toml`](../../mise/config.dev-windows.toml)、[`config.server-pi.toml`](../../mise/config.server-pi.toml)、[`config.ci.toml`](../../mise/config.ci.toml)
- 重ねて読み込むツール定義: [`config.interactive.toml`](../../mise/config.interactive.toml)、[`config.dev.toml`](../../mise/config.dev.toml)、[`config.bun.toml`](../../mise/config.bun.toml)
- 全環境共通のツール定義: [`conf.d/00-tools-all.toml`](../../mise/conf.d/00-tools-all.toml)
- このリポジトリ固有の lint / CI 用ツール: [`.mise.toml`](../../.mise.toml)

## Pins and Backend Choices

### jactionlint

破壊的変更（breaking changes）に備えてバージョンを固定し、更新時に attestation を確認します。定義は [`mise/conf.d/00-tools-all.toml`](../../mise/conf.d/00-tools-all.toml) にあります。

### gh-actions-lock

`.github/workflows/actions.lock` の生成・検証用に、リポジトリルートの [`.mise.toml`](../../.mise.toml) でバージョンを厳密に固定しています。更新先は公開から 7 日以上経過した版に限り、`mise run actions-lock:generate` で lockfile を再生成して差分を確認します。アセットの実行ファイル名も同ファイルで指定しています。

### uv と pnpm

- `uv` は uvx 経由の自己参照を避けるため、`github:astral-sh/uv` backend を使います。
- `pnpm` はメジャーバージョンを固定し、マイナー / パッチ更新を許可します。

### tree-sitter-cli

WSL の glibc 不整合を回避するため cargo backend を使い、不要な default features を無効にしています。設定は [`mise/config.dev-posix.toml`](../../mise/config.dev-posix.toml) にあります。

## Environment-specific Exceptions

- Neovim の Lua 依存は Homebrew で管理しています。ツール管理層の使い分けは [セットアップ方針](../setup.md#package-management-philosophy) を参照してください。
- Raspberry Pi では `luacheck` を mise の管理対象に含めず、`goimports` も `mise/config.server-pi.toml` で無効にしています。理由は同ファイル内のコメントを参照してください。
