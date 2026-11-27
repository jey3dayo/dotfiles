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
timestamp: 2026-11-27
audience: developer
owner: dotfiles
---

# Mise Reference

この文書では `.config` における mise の設定構成とタスクの境界を説明します。どの層でツールを管理するかは [セットアップ方針](../setup.md#package-management-philosophy)、backend の選定やバージョン固定の理由は [Mise Configuration Reference](mise-config.md)、タスクの影響と調べ方は [Mise Task Safety and Discovery](mise-tasks.md) を参照してください。

Claude 向けの短いルールは [`.claude/rules/tools/mise.md`](../../.claude/rules/tools/mise.md) にあります。

## Configuration Structure

`MISE_CONFIG_DIR` で設定ディレクトリを指定し、`MISE_ENV` で適用する環境を選択します。通常はシェル起動時に環境に応じた値が自動で組み立てられます。

標準のグローバル設定探索（global config discovery）により、`config.toml`、`conf.d/`、`config.<env>.toml` の順に読み込みます。`MISE_ENV` に並んだ環境は順に重ねられ、後ろに指定した環境の値が優先されます。

`MISE_CONFIG_FILE` / `MISE_GLOBAL_CONFIG_FILE` は使いません。これらを設定すると探索対象が単一ファイルに置き換わり、環境別設定が読み込まれなくなるためです。`shell/env.sh` でも両変数を明示的に解除しています。

| 環境         | `MISE_ENV`                            |
| ------------ | ------------------------------------- |
| macOS        | `macos,bun,interactive,dev,dev-posix` |
| Linux / WSL2 | `bun,interactive,dev,dev-posix`       |
| Raspberry Pi | `interactive,server-pi`               |
| Windows      | `bun,interactive,dev,dev-windows`     |
| CI           | `bun,ci`                              |

ファイル名は「どの環境が読み込むか」を表しています。各ツールは、それを必要とする環境だけが読み込むファイルに配置します。

| ファイル                   | 読み込む環境              | macOS | Linux / WSL2 | Windows | Pi  | CI  |
| -------------------------- | ------------------------- | :---: | :----------: | :-----: | :-: | :-: |
| `conf.d/00-tools-all.toml` | すべて                    |  ✅   |      ✅      |   ✅    | ✅  | ✅  |
| `config.bun.toml`          | Pi 以外                   |  ✅   |      ✅      |   ✅    |  —  | ✅  |
| `config.interactive.toml`  | CI 以外（人が使うマシン） |  ✅   |      ✅      |   ✅    | ✅  |  —  |
| `config.dev.toml`          | 開発機（Windows を含む）  |  ✅   |      ✅      |   ✅    |  —  |  —  |
| `config.dev-posix.toml`    | Windows 以外の開発機      |  ✅   |      ✅      |    —    |  —  |  —  |
| `config.dev-windows.toml`  | Windows                   |   —   |      —       |   ✅    |  —  |  —  |
| `config.macos.toml`        | macOS                     |  ✅   |      —       |    —    |  —  |  —  |
| `config.server-pi.toml`    | Pi                        |   —   |      —       |    —    | ✅  |  —  |
| `config.ci.toml`           | CI                        |   —   |      —       |    —    |  —  | ✅  |

2026-11 に `shared` → `interactive`、`workstation` → `dev`、`workstation-unix` → `dev-posix`、`workstation-windows` → `dev-windows`、`conf.d/00-tools-common.toml` → `conf.d/00-tools-all.toml` へ改名しました。シェルおよび PowerShell の起動処理は旧トークンも除去して `MISE_ENV` を組み直すため、新しいシェルを開けばそのまま移行できます。macOS の GUI アプリ向けの値は `mise bootstrap` を再実行して更新します。

環境の判定と選択順は [`shell/env.sh`](../../shell/env.sh) と [`windows/setup.ps1`](../../windows/setup.ps1) にあります。

設定は次の役割に分かれています。

- [`mise/config.toml`](../../mise/config.toml): 共通の settings、env、OS 共通の dotfiles。`[tools]` は置かず、OS 間で値が異なる設定も各 OS 別ファイルに置きます。
- [`mise/conf.d/00-tools-all.toml`](../../mise/conf.d/00-tools-all.toml): すべての環境で共通するツール定義。
- `mise/config.*.toml`: `MISE_ENV` で選択する OS・役割ごとのツールや設定。
- [`.mise.toml`](../../.mise.toml): このリポジトリ専用のバージョン固定とタスク include。
- [`mise/local-tasks/`](../../mise/local-tasks/): このリポジトリ専用のタスク定義。PC メンテナンスや資格情報に依存する処理、破壊的な操作を含むタスク群はここに置きます。
- [`mise/tasks/`](../../mise/tasks/): 他のリポジトリからも使うグローバルタスク定義。
- [`mise/lib/`](../../mise/lib/): タスクから呼び出すヘルパースクリプト。

Windows では `mise run` がツールごとに PATH へディレクトリを追加するため、ツール数が増えると cmd の上限（8191 文字）を超えてしまい、タスク内で `node` などが見つからなくなります。そのため Windows は pwsh / git / nvim / フックから呼び出すツールだけに絞った最小構成にしています。`config.dev.toml` には Windows でも使うツールだけを置き、それ以外は `config.dev-posix.toml` に置きます。Raspberry Pi も読み込む `config.interactive.toml` では、Windows で使わないツールに `os = ["linux", "macos"]` を付けて除外します。Rust などリポジトリ側で固定するツールは各リポジトリの `mise.toml` に任せます。Windows が受け取るツール数の上限は [`scripts/mise-config.test.ts`](../../scripts/mise-config.test.ts) で検査しています。

`mise/tasks/` に置くグローバルタスクは外部リポジトリからも参照できるため、カレントディレクトリに依存しないか `dir` を明示できるもの、かつ全ディレクトリに公開する理由があるものに限ります。タスク定義の TOML は薄い呼び出し口に留め、条件分岐・後処理・複数コマンドの組み合わせは `mise/lib/` または `scripts/` に切り出します。

公開直後のバージョンへの更新を `minimum_release_age` で遅らせ、例外は `minimum_release_age_excludes` で定義します。ツール構成と待機期間の実値は、それぞれの mise 設定ファイルを参照してください。この文書ではパッケージ一覧を複製しません。

タスクの対象ファイルや除外パスを制御する環境変数も [`mise/config.toml`](../../mise/config.toml) にあります。対象を絞るときは、関連タスクが参照する変数と現在の値を先に確認してください。リポジトリ固有のバージョン固定やタスクの include は、各リポジトリの `.mise.toml` で管理します。

## Task Boundaries

- `update` / `check` / 通常の `ci` は非破壊的に保ちます。`reset`、`clean`、`prune`、deploy、in-place restore は明示的な個別タスクに置きます。
- `mise run ci` はローカル検証、`mise run ci:full` は検証に dotfiles の適用・確認を加えます。
- `mise bootstrap` はマシン全体の状態を宣言どおりに収束させます。`mise dotfiles status` は配布状態を確認し、`mise dotfiles apply` は dotfiles を適用します。
- `mise run update` は設定済みの更新処理を実行します。submodule 更新や外部リポジトリの強制リセットは別タスクです。
- `format` 系タスクはファイルを書き換えます。`format:*:check` は確認のみで、ファイルを変更しません。その他の状態変更タスクの詳細は `mise tasks info <task>` で確認してください。

タスク一覧は `mise tasks`、1 件の定義は `mise tasks info ci` のように確認します。実行影響の分類は [Mise Task Safety and Discovery](mise-tasks.md) を参照してください。

## Troubleshooting

- `mise doctor`: mise の状態を診断します。
- `mise current`: 現在のディレクトリで有効なツールバージョンを表示します。
- `mise which <tool>`: 解決された実行ファイルの場所を表示します。

mise 管理ツールは shim 経由で解決されるため、通常は利用前に `command -v` や `which` で存在確認を行う必要はありません。

APM の編集・検証・配布は [APM Workspace](apm-workspace.md) を参照してください。
