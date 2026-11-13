---
type: reference
title: Mise Task Safety and Discovery
description: mise タスクの実行影響、調べ方、状態変更を伴うタスクの注意点
resource: docs/tools/mise-tasks.md
tags:
  - category/configuration
  - layer/tool
  - tool/mise
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# Mise Task Safety and Discovery

最終更新: 2026-11-13
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

タスク名と現在の定義は `mise tasks` で一覧し、個別の動作は `mise tasks info <task>` で確認します。定義は [`mise/local-tasks/`](../../mise/local-tasks/) と [`mise/tasks/`](../../mise/tasks/) にあります。完全なタスク一覧をこの文書へ複製しません。

## Execution Impact

| 影響             | 例                                                                                                          | 実行前に見る点                                                                                                                                                                                               |
| ---------------- | ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 検証のみ         | `ci`、`ci:quick`、`check`、`format:*:check`、`brewfile:diff`、`audit:orphans`、`mise dotfiles status`       | 通常の品質確認として実行できます。                                                                                                                                                                           |
| 作業ツリー変更   | `format`、書き込みを行う `format:*`                                                                         | `format:*:check` はファイルを書き換えません。書き込みタスクは対象と差分を確認します。                                                                                                                        |
| ローカル状態変更 | `ci:full`、`ci:verify-deploy`、`mise bootstrap`、`setup`、`brewfile:restore`、`mise dotfiles apply --force` | `ci:full` と `ci:verify-deploy` は内部で `mise dotfiles apply --yes --force` を実行し、既存の対象ファイルを上書きします。これらと `mise dotfiles apply --force` は、ユーザー確認なしで実行しないでください。 |
| 外部取得・更新   | `update`、`update:brew`、`update:mise`                                                                      | 取得元と更新対象を確認します。                                                                                                                                                                               |
| 破棄を伴う更新   | `update:submodules`、`update:external-repos`                                                                | `update:submodules` はローカル変更を破棄し、`update:external-repos` は外部 checkout を強制リセットします。必要な状態を保全し、ユーザー確認なしで実行しないでください。                                       |
| secret 関連      | `setup-env`、`env:encrypt`、`env:decrypt`、`env:print`、`ci:gitleaks`                                       | 暗号化ファイル・復号先・出力先を確認します。秘密値を共有ログへ出さないでください。                                                                                                                           |

`mise bootstrap --dry-run` は適用前の差分確認に使います。`mise tasks info <task>` で対象や実行内容が分からない場合は、該当する TOML と helper script を確認してから実行してください。

## Ownership and References

- 設定ファイルの役割と環境選択: [Mise Reference](mise.md)
- backend や pin 固定の理由: [Mise Configuration Reference](mise-config.md)
- mise / Homebrew / Chocolatey の使い分け: [Package Management Philosophy](../setup.md#package-management-philosophy)
- Brewfile の例外と cleanup の注意: [Workflows and Maintenance](workflows.md#brewfile)
- APM の詳細な操作・検証・配布: [APM Workspace](apm-workspace.md)
