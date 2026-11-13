---
type: reference
title: Git Configuration
description: .config が管理する Git 設定とユーザー別の上書き
resource: docs/tools/git.md
tags:
  - category/configuration
  - layer/tool
  - tool/git
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# Git Configuration

最終更新: 2026-11-13  
対象: 開発者  
タグ: `category/configuration`, `tool/git`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Git の共通設定ファイルは `git/config` です。`shell/env.sh` が `GIT_CONFIG_GLOBAL` を `${XDG_CONFIG_HOME}/git/config` に設定します。`git/config` は機能別ファイルと `~/.gitconfig_local` を読み込みます。

## Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/git.md`](../../.claude/rules/tools/git.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 構成と読み込み順

```text
~/.config/git/                  # dotfiles 管理
├── config                      # メイン設定（GIT_CONFIG_GLOBAL から参照）
├── alias.gitconfig             # エイリアス/ショートカット
├── diff.gitconfig              # delta/diff 設定
├── ghq.gitconfig               # ghq のルート設定
├── 1password.gitconfig         # 1Password 署名設定（任意で include）
├── attributes                  # グローバル gitattributes
└── local.gitconfig             # ローカル用サンプル（自動読込はしない）

~/.gitconfig_local              # Git 管理外。ユーザー/職場ごとの上書き用
```

読み込み順は以下の通りです（後ろほど優先）。

1. `config` 本体（このリポジトリで管理）
2. `diff.gitconfig` / `ghq.gitconfig` / `alias.gitconfig`（機能別設定）
3. `~/.gitconfig_local`（ユーザー・環境固有の上書き）

## ローカル上書きの扱い

`~/.gitconfig_local` に個人情報・職場固有設定を記載します。初期化例を示します。

```ini
[user]
  name = Your Name
  email = your.email@example.com
```

SSH 署名先や会社プロキシ設定などもここにのみ記載します。Git 管理対象のファイルには含めません。

## 1Password での署名（任意）

1Password の SSH 署名を有効化する場合は、既存の include を壊さないよう **必ず --add で追記** するか、`~/.gitconfig_local` に記述します。

```bash
git config --global --add include.path ~/.config/git/1password.gitconfig
# または ~/.gitconfig_local に下記を追記
# [include]
#   path = ~/.config/git/1password.gitconfig
```

`1password.gitconfig` は GPG 署名に SSH フォーマットを使うための設定のみを持ち、他の設定に影響しません。

## 動作確認

- `git config --list --show-origin` で読み込み元を確認
- `git config user.name` でローカル上書きが効いているか確認
