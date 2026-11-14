---
type: reference
title: Mise Reference
description: .config における mise の環境選択、設定境界、タスクの使い分け
resource: docs/tools/mise.md
tags:
  - category/configuration
  - layer/tool
  - tool/mise
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-14
audience: developer
owner: dotfiles
---

# Mise Reference

最終更新: 2026-11-14
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

この文書では `.config` の mise 設定とタスクの境界を説明します。どの層でツールを管理するかは [セットアップ方針](../setup.md#package-management-philosophy)、backend や pin 固定の理由は [Mise Configuration Reference](mise-config.md)、タスクの影響と調べ方は [Mise Task Safety and Discovery](mise-tasks.md) を参照してください。

## Configuration Structure

`MISE_CONFIG_DIR` は設定ディレクトリを指定し、`MISE_ENV` は適用する環境を選びます。shell startup が通常の環境値を組み立てます。

標準の global config discovery で `config.toml`、`conf.d/`、`config.<env>.toml` を読み込みます。`MISE_ENV` の設定は順に重ね、後ろにある環境の値を優先します。

`MISE_CONFIG_FILE` / `MISE_GLOBAL_CONFIG_FILE` は使いません。設定探索を単一ファイルに置き換え、環境別設定を読めなくするためです。`shell/env.sh` でも両変数を解除しています。

| 環境         | `MISE_ENV`                                      |
| ------------ | ----------------------------------------------- |
| macOS        | `macos,bun,shared,workstation,workstation-unix` |
| Linux / WSL2 | `bun,shared,workstation,workstation-unix`       |
| Raspberry Pi | `shared,server-pi`                              |
| Windows      | `bun,shared,workstation,workstation-windows`    |
| CI           | `bun,ci`                                        |

環境の判定と選択順は [`shell/env.sh`](../../shell/env.sh) と [`windows/setup.ps1`](../../windows/setup.ps1) にあります。

設定は次の役割に分かれています。

- [`mise/config.toml`](../../mise/config.toml): 共通 settings、env、OS 共通 dotfiles。`[tools]` は置かず、OS 間で値が異なる設定も各 OS 別ファイルに置きます。
- [`mise/conf.d/00-tools-common.toml`](../../mise/conf.d/00-tools-common.toml): すべての環境で共通する tools。
- `mise/config.*.toml`: `MISE_ENV` で選ぶ OS・役割ごとの tools や設定。
- [`.mise.toml`](../../.mise.toml): この repo 専用の tool pin と task include。
- [`mise/local-tasks/`](../../mise/local-tasks/): この repo 専用の task 定義。PC メンテナンス、資格情報に依存する処理、破壊的な task family はここに置きます。
- [`mise/tasks/`](../../mise/tasks/): 他の repo からも使う task 定義。
- [`mise/lib/`](../../mise/lib/): task から呼び出す helper scripts。

Windows では `mise run` が tool ごとに PATH へ dir を足すため、tool が増えると cmd の上限（8191 文字）を超え、task 内で `node` などが見つからなくなります。Windows が読む `config.shared.toml` / `config.workstation.toml` には Windows でも使う tool だけを置き、Windows で不要な workstation tool は `config.workstation-unix.toml` の Windows 除外区画に置きます。Windows が受け取る tool 数の上限は [`scripts/mise-config.test.ts`](../../scripts/mise-config.test.ts) で検査します。

`mise/tasks/` の global task は外部 repo にも見えるため、cwd 非依存か `dir` を明示し、全ディレクトリに公開する理由があるものに限ります。Task TOML は薄い runner とし、分岐・cleanup・複数 command は `mise/lib/` または `scripts/` に置きます。

公開直後のバージョンへの更新を `minimum_release_age` で遅らせ、例外は `minimum_release_age_excludes` で定義します。ツール構成と待機期間の実値は、それぞれの mise 設定ファイルを参照してください。この文書ではパッケージ一覧を複製しません。

task の対象ファイルや除外パスを制御する環境変数も [`mise/config.toml`](../../mise/config.toml) にあります。対象を絞るときは、関連タスクが参照する変数と現在の値を先に確認してください。repo 固有の version pin と task include は、その repo の `.mise.toml` で管理します。

## Task Boundaries

- `update` / `check` / 通常の `ci` は非破壊的に保ちます。`reset`、`clean`、`prune`、deploy、in-place restore は明示的な個別タスクに置きます。
- `mise run ci` はローカル検証、`mise run ci:full` は検証に dotfiles の適用・確認を加えます。
- `mise bootstrap` は machine state を収束させます。`mise dotfiles status` は配布状態を確認し、`mise dotfiles apply` は dotfiles を適用します。
- `mise run update` は設定済みの更新処理を実行します。submodule 更新や外部 repo の強制リセットは別タスクです。
- `format` 系タスクはファイルを書き換えます。`format:*:check` は確認のみで、ファイルを変更しません。その他の状態変更タスクの詳細は `mise tasks info <task>` で調べてください。

タスク一覧は `mise tasks`、1件の定義は `mise tasks info ci` のように確認します。実行影響の分類は [mise task guide](mise-tasks.md) を参照してください。

## Troubleshooting

- `mise doctor`: mise の状態を診断します。
- `mise current`: 現在のディレクトリで有効な tool version を表示します。
- `mise which <tool>`: 解決された実行ファイルの場所を表示します。

mise 管理ツールは shim で解決するため、通常はそれらの利用前に `command -v` / `which` で存在確認する処理を書きません。

APM の編集、検証、配布は [APM Workspace](apm-workspace.md) を参照してください。
