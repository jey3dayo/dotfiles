---
type: index
title: Documentation
description: dotfiles のセットアップ、運用、ツール設定に関する文書の索引
resource: docs/README.md
tags:
  - category/guide
  - layer/support
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Documentation

手順と運用ルールはトピックごとのガイドにまとめています。リポジトリの概要は [README](../README.md)、AI 協働ルールは [AGENTS.md](../AGENTS.md) を参照してください。

## Setup and operations

- [Setup Guide](setup.md) - 導入手順、初期設定、検証方法、ツール管理方針
- [Workflows & Maintenance](tools/workflows.md) - 定期メンテナンス、品質確認、Brewfile 管理
- [Security](security.md) - 秘密情報の分類、gitleaks 運用、インシデント対応
- [Disaster Recovery](disaster-recovery.md) - `mise bootstrap` 環境の復旧手順
- [Documentation Governance](documentation.md) - 文書の役割分担、メタデータ規約、更新ルール

## Tool guides

### Environment and operations

- [Mise](tools/mise.md) - mise の環境選択、設定構成、タスクの境界
  - [Task Safety & Discovery](tools/mise-tasks.md) - タスクの調べ方と実行時の影響確認
  - [Config Reference](tools/mise-config.md) - mise 設定ファイルの役割とバージョン固定の理由
- [APM Workspace](tools/apm-workspace.md) - 共通スキル・エージェント・ガイドの編集元と配布先
- [1Password CLI](tools/1password.md) - CLI 認証、環境変数の 2 層管理、service account の運用

### Shell and development tools

- [Git](tools/git.md) - Git 設定の階層構造、読み込み順、worktree フック
- [Zsh](tools/zsh.md) - シェル構成、遅延ロード方針、読み込み順
- [FZF](tools/fzf-integration.md) - Git・シェル間の統合とキーバインド
- [Neovim](tools/nvim.md) - エディタ設定、LSP、プラグイン管理
- [Ghostty](tools/ghostty.md) - Ghostty ターミナルの設定と `Ctrl+B` リーダーキー
- [WezTerm](tools/wezterm.md) - WezTerm ターミナルの設定とキーバインド
- [Karabiner-Elements](tools/karabiner.md) - macOS のキーバインド設定とリーダーキー実装パターン
- [SSH](tools/ssh.md) - SSH の階層設定と診断手順
