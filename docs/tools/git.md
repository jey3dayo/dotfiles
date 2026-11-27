---
type: reference
title: Git Configuration
description: .config が管理する Git 設定、読み込み順、worktree フック、ユーザー別の上書き
resource: docs/tools/git.md
tags:
  - category/configuration
  - layer/tool
  - tool/git
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Git Configuration

Git の共通設定ファイルは `git/config` です。`shell/env.sh` が `GIT_CONFIG_GLOBAL` を `${XDG_CONFIG_HOME}/git/config` に設定し、`git/config` から機能別ファイルと `~/.gitconfig_local` を読み込みます。

Claude 向けの短いルールは [`.claude/rules/tools/git.md`](../../.claude/rules/tools/git.md) にあります。

## 構成と読み込み順

```text
~/.config/git/                  # dotfiles 管理
├── config                      # メイン設定（GIT_CONFIG_GLOBAL から参照）
├── alias.gitconfig             # エイリアス / ショートカット
├── diff.gitconfig              # delta / diff 設定
├── ghq.gitconfig               # ghq のルート設定
├── 1password.gitconfig         # 1Password 署名設定（任意で include）
├── attributes                  # グローバル gitattributes
├── local.gitconfig             # ローカル用サンプル（自動読み込みはしません）
├── hooks/
│   └── post-checkout           # 新規 worktree へ gitignore 対象の .env 系を symlink するフック
├── template/
│   └── hooks/post-checkout     # init.templateDir 経由で配布するフックのリンク
└── wt-hook.sh                  # git-wt で新規 worktree 作成時に mise / 依存を導入するフック

~/.gitconfig_local              # Git 管理外。ユーザー / 職場ごとの上書き用
```

`git/config` 内での読み込み順は以下のとおりです（後ろほど優先されます）。

1. `diff.gitconfig` / `ghq.gitconfig` / `alias.gitconfig`（`git/config` 冒頭で include する機能別設定）
2. `git/config` 本体（このリポジトリで管理する共通設定）
3. `~/.gitconfig_local`（`git/config` 末尾で include するユーザー・環境固有の上書き）

## worktree フック

- `git/hooks/post-checkout`（`init.templateDir = ~/.config/git/template` で配布）: 新しいリンク worktree を作成した際、メイン側にある `.gitignore` 対象の `.env` 系ファイルを symlink で引き継ぎます。既存ファイルは上書きせず、失敗しても checkout 自体は止めません。
- `git/wt-hook.sh`（`wt.hook` で実行）: `git-wt` で新しい worktree を作成した際、信頼済みの `mise` 設定があれば `mise install` と lockfile に応じた依存関係のインストールを実行します。

## ローカル上書きの扱い

`~/.gitconfig_local` に個人情報や職場固有の設定を記載します。初期化例は次のとおりです。

```ini
[user]
  name = Your Name
  email = your.email@example.com
```

SSH 署名鍵の指定や社内プロキシ設定などもこのファイルのみに記載し、Git 管理対象のファイルには含めません。

## 1Password での署名（任意）

1Password の SSH 署名を有効化する場合は、既存の include を壊さないよう **必ず `--add` で追記**するか、`~/.gitconfig_local` に記述します。

```bash
git config --global --add include.path ~/.config/git/1password.gitconfig
# または ~/.gitconfig_local に下記を追記
# [include]
#   path = ~/.config/git/1password.gitconfig
```

`1password.gitconfig` は 1Password による SSH コミット署名を有効にする設定のみを持ち、他の設定には影響しません。

## 動作確認

- `git config --list --show-origin` で各設定の読み込み元を確認します。
- `git config user.name` でローカル上書きが反映されているか確認します。
