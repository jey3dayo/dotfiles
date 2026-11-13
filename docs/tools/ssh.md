---
type: guide
title: SSH Configuration
description: SSH 設定の Include 構造、プラットフォーム別設定、ホスト追加と診断手順
resource: docs/tools/ssh.md
tags:
  - category/configuration
  - tool/ssh
  - layer/tool
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# SSH Configuration

SSH の設定は共通設定、プラットフォーム別設定、ローカル設定の順で読み込みます。

## Claude Rules

このドキュメントの凝縮版ルールは [`.claude/rules/tools/ssh.md`](../../.claude/rules/tools/ssh.md) で管理されています。

- 目的: Claude AIが常に参照する簡潔なルール
- 適用範囲: YAML frontmatter `paths:` で定義
- 関係: 本ドキュメントが詳細リファレンス（SST）、Claudeルールが強制版

## 設定構造

エントリポイントの [`ssh/config`](../../ssh/config) は、共通設定、条件に合うプラットフォーム設定、ローカル設定をこの順で Include します。共通設定ファイルは英数字順に読み込みます。

| 設定                                                                                               | 内容                                        |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| [`config.d/common/00-global.sshconfig`](../../ssh/config.d/common/00-global.sshconfig)             | 全ホスト共通の接続・認証設定                |
| [`config.d/common/01-1password.sshconfig`](../../ssh/config.d/common/01-1password.sshconfig)       | 1Password SSH Agent の設定                  |
| [`config.d/common/10-dev-services.sshconfig`](../../ssh/config.d/common/10-dev-services.sshconfig) | 開発サービスの設定                          |
| [`config.d/common/20-home-network.sshconfig`](../../ssh/config.d/common/20-home-network.sshconfig) | ホームネットワークのホスト設定              |
| [`config.d/macos/settings.sshconfig`](../../ssh/config.d/macos/settings.sshconfig)                 | `uname -s` が `Darwin` のときに読み込む設定 |
| [`config.d/linux/settings.sshconfig`](../../ssh/config.d/linux/settings.sshconfig)                 | `uname` が `Linux` を含むときに読み込む設定 |

ローカル設定は `~/.ssh/ssh_config.d/*` に置きます。このディレクトリは Git 管理外です。

## プラットフォーム固有設定

- macOS では SSH のキーチェーン連携と Agent 登録を全ホストに適用します。OrbStack と Colima の Include は既定でコメントアウトされています。
- Linux 設定は現在、空のプレースホルダーです。WSL2 用の条件分岐は例としてコメントアウトされています。

## 1Password SSH Agent

設定は [`config.d/common/01-1password.sshconfig`](../../ssh/config.d/common/01-1password.sshconfig) にあります。現在は無効です。利用する場合は、次の手順で有効にして確認します。

1. 1Password の設定で SSH Agent を有効にします。
2. 同ファイルにある1Password用ブロックのコメントを解除します。
3. `ssh-add -l` で Agent の状態を確認します。

## ホスト追加手順

1. [`host-template.sshconfig`](../../ssh/templates/host-template.sshconfig) をコピーします。
2. 用途に応じて適切な設定ファイルを選択します。
3. `HostName`、`User`、`Port` を設定します。
4. `ssh -T hostname` で接続を確認します。

## 診断

設定の確認には `ssh -G` を使います。macOS と Linux/WSL2 で適用される内容を確認できます。

```bash
ssh -G github.com | grep -i keychain
```

接続の詳細を確認するときは詳細ログを使います。タイムアウト時はまず [`00-global.sshconfig`](../../ssh/config.d/common/00-global.sshconfig) の接続設定を確認します。

```bash
ssh -vvv hostname
```

## ControlPath

共通設定の ControlPath が使う `~/.ssh/sockets/` を事前に作成し、所有者だけがアクセスできる権限にします。

```bash
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh/sockets
```
