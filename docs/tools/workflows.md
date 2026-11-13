---
type: reference
title: Workflows and Maintenance
description: .config の検証、Git hooks、Brewfile の運用上の注意
resource: docs/tools/workflows.md
tags:
  - category/maintenance
  - layer/tool
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# Workflows & Maintenance Reference

最終更新: 2026-11-13
対象: 開発者
タグ: `category/maintenance`, `layer/tool`, `environment/cross-platform`, `audience/developer`

## Maintenance Cadence

| 頻度   | 作業                                                                                                                                        |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| 週次   | `mise run update`（cask は対象外。必要なら `brew upgrade --cask`）、`mise run update:standalone`、sheldon / Neovim `vim.pack` / tmux の更新 |
| 月次   | 起動時間の計測（[Zsh](zsh.md#検証) / [Neovim](nvim.md#検証)）、ログ整理、`mise prune`、`mise bootstrap --yes`                               |
| 四半期 | 設定監査、依存関係の整理、バックアップの復元確認                                                                                            |

## Verification and Git Hooks

`mise run ci` はローカルで CI の検証を実行します。タスクの定義は [`mise/local-tasks/`](../../mise/local-tasks/) を参照してください。

`lefthook.yml` が Git hook の実行内容を定義します。

- `pre-commit` は staged files に対して該当する formatter / linter を実行し、staged content を gitleaks で検査します。
- `pre-push` は変更ファイルの種類に応じて `check:format`、`check:lint:quick`、TypeScript / Lua / Neovim のテストを実行し、gitleaks は毎回実行します。ネットワークが必要な `lint:links` はこの hook に含みません。

初回は `lefthook install` で hook を設定します。手動実行は `lefthook run pre-commit` または `lefthook run pre-push`、全体の検証は `mise run ci` です。別に `mise run pre-push` タスクもあり、変更ファイルに応じた追加テストを選びます。

hook やタスクの対象・引数を変えるときは `lefthook.yml` と該当する `mise/local-tasks/*.toml` を更新します。実行処理が helper script に委譲されている場合は、その定義も確認してください。

### Changes that need extra checks

| 変更領域            | 確認                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Zsh 起動            | `zsh-benchmark --runs 8 --mode interactive`。詳細は [Zsh の検証](zsh.md#検証) を参照します。                                                                             |
| dotenvx / `.env`    | `scripts/setup-env.sh` の構文、秘密値を表示しない key-set 比較、`mise run ci:gitleaks` を確認します。運用手順は [1Password / dotenvx](1password.md) を参照してください。 |
| launchd / GUI env   | `launchctl getenv <KEY>` で allowlist 済みのキーだけ確認します。                                                                                                         |
| mise bootstrap      | 適用前に `mise bootstrap --dry-run`、適用状態は `mise dotfiles status` で確認します。                                                                                    |
| APM / global skills | [APM Workspace](apm-workspace.md) を正本として、そこで指定された検証を実行します。                                                                                       |

## Brewfile

ツールをどの層で管理するかは [Package Management Philosophy](../setup.md#package-management-philosophy) を参照してください。formula の宣言管理は mise bootstrap が担い、Brewfile は cask / MAS / VS Code 拡張と例外を保持します。

| パッケージ | 設定                        | 理由                     |
| ---------- | --------------------------- | ------------------------ |
| `mysql`    | `restart_service: :changed` | 更新時にサービスを再起動 |
| `utf8proc` | `args: ["HEAD"]`            | Julia の依存関係         |

`mise run brewfile:diff` はインストール状態と Brewfile の差分を報告し、Brewfile は変更しません。「未インストール」はマシンごとの差として起きるため、それだけで削除対象にしません。

`brew bundle cleanup` は実行しないでください。Brewfile にない formula も削除候補にするため、mise bootstrap が管理する formula を削除するおそれがあります。削除候補を調べる場合は [`mise/tasks/brewfile.toml`](../../mise/tasks/brewfile.toml) と [セットアップ方針](../setup.md#package-management-philosophy) を確認してください。

`mise bootstrap packages prune` も実運用では使いません。Brewfile 専用の例外（`mysql` / `utf8proc` / `perman-aws-vault` / `mise` / tap formulae）も削除対象になるためです。

## Troubleshooting Routing

- Zsh / Neovim の起動や設定: [Zsh](zsh.md) / [Neovim](nvim.md)
- mise の設定・タスク: [Mise Reference](mise.md) / [Mise Task Catalog](mise-tasks.md)
- APM の編集・配布: [APM Workspace](apm-workspace.md)
- dotfiles の適用前確認: `mise bootstrap --dry-run` または `mise dotfiles status`
- `.env` と資格情報: [1Password / dotenvx](1password.md)
- バックアップ・復旧: [Disaster Recovery](../disaster-recovery.md)
