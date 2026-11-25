---
type: runbook
title: Disaster Recovery Guide
description: mise bootstrap で管理する dotfiles 環境の障害発生時の復旧手順
resource: docs/disaster-recovery.md
tags:
  - category/maintenance
  - layer/support
  - tool/mise
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-25
audience: developer
owner: dotfiles
---

# Disaster Recovery Guide

`mise bootstrap` で配布している dotfiles 環境で障害が発生した際の復旧手順をまとめています。旧 Nix Home Manager ベースの復旧手順は撤去済みのため、generation ロールバックは利用できません。変更履歴は Git を正本として扱います。

## シナリオ A: 最近の変更をロールバックする

### 適用ケース

- 設定変更後にシェルやツールの動作が不安定になった

### 手順

```bash
cd ~/.config
git log --oneline -10          # 問題のコミットを特定
git revert <commit>            # 履歴を保ったまま打ち消す
mise dotfiles apply --yes      # 配布を再収束
```

`main` 上では `git reset --hard` や `git restore` による変更破棄を行いません（実行する場合は必ず事前に確認します）。

## シナリオ B: 配布ファイルの破損・消失

### 適用ケース

- `~/.zshenv` などの symlink が消えた、または別ファイルを指している
- launchd agent が消えた

### 手順

```bash
mise dotfiles status           # differs / missing を確認
mise dotfiles apply --yes      # 再適用（冪等）
mise bootstrap status          # packages / launchd を含む全体確認
mise bootstrap --yes           # マシン全体を収束
```

競合で拒否された場合のみ `mise dotfiles apply --force` を実行します。既存ファイルを上書きするため、実行前に差分や内容を確認してください。

## シナリオ C: シェルが起動しない

```bash
zsh --no-rcs                   # rc なしで起動
cd ~/.config && git status     # リポジトリの状態確認
mise dotfiles apply --yes      # エントリポイントを再配布
exec zsh
```

`mise` 自体が壊れている場合は、公式インストーラで再導入してから再配布します。

```bash
curl https://mise.run | sh     # ~/.local/bin/mise に再インストール
~/.local/bin/mise dotfiles apply --yes
```

## シナリオ D: リポジトリ自体の消失

```bash
git clone https://github.com/jey3dayo/dotfiles ~/.config
cd ~/.config
brew bundle                    # macOS のみ
mise trust && mise bootstrap --yes
exec zsh
```

secret 類（`.env.local` など）は restic バックアップから復元します。

```bash
mise run backup:snapshots      # スナップショット一覧を確認
mise run backup:restore        # ./restore に最新スナップショットを復元
```

## 検証チェックリスト

復旧後は以下を実行し、環境が正常に収束しているか確認します。

```bash
mise bootstrap status --missing   # 全宣言部が収束しているか確認（exit 0）
zsh -lic 'echo ok'                # シェル起動を確認
git config user.name              # Git 設定（~/.gitconfig_local 経由）を確認
mise doctor                       # mise 全体の健全性を確認
```

macOS ではあわせて launchd agents の状態も確認します。

```bash
mise bootstrap macos launchd-agents status
```

## 関連ドキュメント

- [Setup Guide](setup.md) — 新規マシンのセットアップ手順
- [Workflows & Maintenance](tools/workflows.md) — 定期メンテナンスと日常検証
