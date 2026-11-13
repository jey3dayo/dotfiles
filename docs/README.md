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
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# Documentation

手順と運用ルールはトピックごとのガイドに記載しています。リポジトリの概要は [README](../README.md)、AI 協働ルールは [AGENTS.md](../AGENTS.md) を参照してください。

## Setup and operations

- [Setup Guide](setup.md) - インストール、初期設定、検証手順
- [Workflows & Maintenance](tools/workflows.md) - 定期メンテナンス、品質確認、Brewfile 管理
- [Security](security.md) - 秘密情報、gitleaks、インシデント対応
- [Disaster Recovery](disaster-recovery.md) - mise bootstrap 環境の復旧手順
- [Documentation Governance](documentation.md) - 文書の役割、metadata、更新ルール

## Tool guides

### Environment and operations

- [Mise](tools/mise.md) - mise 設定とタスク設計
  - [Task Catalog](tools/mise-tasks.md) - タスクの検索、使い方、実行時の影響確認
  - [Config Reference](tools/mise-config.md) - mise 設定ファイルとツール構成
- [APM Workspace](tools/apm-workspace.md) - 共通 skill・agent・ガイドの編集先と配布先
- [1Password CLI](tools/1password.md) - CLI 認証と service account の運用

### Shell and development tools

- [Git](tools/git.md) - Git 設定と include 順序
- [Zsh](tools/zsh.md) - shell 構成と読み込み順
- [FZF](tools/fzf-integration.md) - Git・shell 間の統合とキーバインド
- [Neovim](tools/nvim.md) - エディタ設定、LSP、プラグイン
- [WezTerm](tools/wezterm.md) - terminal 設定とキーバインド
- [SSH](tools/ssh.md) - SSH の階層設定とセキュリティ
