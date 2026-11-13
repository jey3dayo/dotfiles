---
type: reference
title: FZF Integration Guide
description: Zsh と Git における FZF のキーバインドと設定箇所
resource: docs/tools/fzf-integration.md
tags:
  - category/integration
  - layer/tool
  - tool/fzf
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# FZF Integration Guide

最終更新: 2026-11-13
対象: 開発者
タグ: `category/integration`, `tool/fzf`, `layer/tool`, `environment/cross-platform`, `audience/developer`

FZF は Zsh のファイル・リポジトリ・プロセス選択と Git 操作に使います。履歴検索の `Ctrl+R` は atuin が担当します。

Claude 向けの短いルールは [`.claude/rules/tools/fzf-integration.md`](../../.claude/rules/tools/fzf-integration.md) にあります。

## Key Bindings

### Global

| キー           | 機能                                  | 実装                |
| -------------- | ------------------------------------- | ------------------- |
| `^]`           | ghq リポジトリ選択                    | `zsh/lib/fzf.zsh`   |
| `^gx` / `^g^x` | プロセス選択・kill                    | `zsh/lib/fzf.zsh`   |
| `^T`           | ファイル選択                          | `zsh/lib/fzf.zsh`   |
| `^R`           | コマンド履歴検索（atuin、FZF 不使用） | `zsh/lib/atuin.zsh` |

### Git

| キー           | 機能                                                    | 実装                      |
| -------------- | ------------------------------------------------------- | ------------------------- |
| `^gg` / `^g^g` | Git 操作メニュー                                        | `zsh/lib/git-widgets.zsh` |
| `^gs` / `^g^s` | `git status -sb` をバッファへ挿入・実行                 | `zsh/lib/git-widgets.zsh` |
| `^ga` / `^g^a` | `git add -p` をバッファへ挿入・実行                     | `zsh/lib/git-widgets.zsh` |
| `^gb` / `^g^b` | `gh browse` でリポジトリを開く                          | `zsh/lib/git-widgets.zsh` |
| `^gB`          | ブランチ切り替え。対象が別 worktree にあれば移動        | `zsh/lib/git-widgets.zsh` |
| `^gW` / `^g^W` | worktree メニュー（開く・作成・一覧・整理）             | `zsh/lib/git-widgets.zsh` |
| `^gw` / `^g^w` | fzf-git の worktree 一覧。自動移動せず、`Ctrl+X` で削除 | `fzf-git.sh`              |
| `^gz` / `^g^z` | fzf-git の stash 一覧。`Ctrl+X` で削除                  | `fzf-git.sh`              |
| `^g^f`         | fzf-git の Git file / diff picker                       | `fzf-git.sh`              |
| `^g?`          | fzf-git のキーバインド一覧                              | `fzf-git.sh`              |

`gco` は静的な `git checkout` abbreviation です。`^gs` / `^ga` は Git コマンドをバッファへ挿入して実行します。`^gB` はこの repo のブランチ切り替え機能で、既存 worktree のブランチを選ぶとその worktree へ移動します。

## Configuration and Troubleshooting

- FZF の既定オプション、ファイル検索、`^]` / `^T` / `^gx` の設定は [`zsh/lib/fzf.zsh`](../../zsh/lib/fzf.zsh) にあります。
- fzf-tab の候補表示設定は [`zsh/lib/fzf-tab.zsh`](../../zsh/lib/fzf-tab.zsh) にあります。
- fzf-git と Git widget の読み込み・キーバインドは [`zsh/lib/git-widgets.zsh`](../../zsh/lib/git-widgets.zsh) と [`zsh/sheldon/plugins.toml`](../../zsh/sheldon/plugins.toml) を確認してください。
- FZF が見つからない場合は `mise install` を実行します。FZF は [mise の workstation 設定](../../mise/config.workstation.toml)で管理します。
- Tab 補完が表示されない場合は fzf-tab の設定と sheldon の plugin 定義を確認し、Zsh を再起動します。

mise と Homebrew のどちらでツールを管理するかは [セットアップ方針](../setup.md#package-management-philosophy) を参照してください。
