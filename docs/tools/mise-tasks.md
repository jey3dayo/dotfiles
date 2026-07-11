# Mise Task Catalog

最終更新: 2026-06-29
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)
親ドキュメント: [Mise Reference](mise.md)

全タスク一覧（`mise tasks` でも確認可能）。

## 実行影響の分類

通常の確認は「検証のみ」タスクを優先し、状態変更を伴うタスクは目的と対象を確認してから実行します。

| 分類             | 意味                                           | 代表タスク                                               | 実行前確認                                  |
| ---------------- | ---------------------------------------------- | -------------------------------------------------------- | ------------------------------------------- |
| 検証のみ         | ファイル・システム状態を書き換えない           | `ci`, `ci:quick`, `check`, `mise dotfiles status`        | 通常の品質確認として実行可                  |
| 作業ツリー変更   | フォーマットなどで repo 内ファイルを書き換える | `format`, `format:*`                                     | 差分が対象範囲内か確認する                  |
| ローカル状態変更 | mise、Homebrew、dotfiles などを変更する        | `ci:full`, `ci:verify-deploy`, `mise bootstrap`, `setup` | 現在の machine state と rollback 手順を確認 |
| 外部取得・更新   | ネットワーク取得や外部 checkout を更新する     | `update`, `update:brew`, `update:submodules`             | 取得元と更新対象を確認する                  |
| 強制更新         | 外部 repo を reset するなど破壊的になり得る    | `update:external-repos`, `mise dotfiles apply --force`   | ユーザー確認なしで実行しない                |
| secret 関連      | 暗号化 env や secret scan に触れる             | `env:encrypt`, `env:decrypt`, `setup-env`, `ci:gitleaks` | source of truth と展開先を確認する          |

### CI / 検証

`ci.toml`, `integration.toml` で定義。

| タスク             | 説明                                                  |
| ------------------ | ----------------------------------------------------- |
| `ci:quick`         | 軽量チェック（format + lint のみ、~3-5s、hooks 向け） |
| `ci`               | 全 CI チェック（検証のみ、書き込みなし）              |
| `ci:full`          | CI チェック + デプロイ + 検証（GitHub Actions 同等）  |
| `ci:gitleaks`      | gitleaks による secret スキャン                       |
| `ci:install`       | CI 必要ツールをインストール（luacheck, busted）       |
| `check`            | CI 向け総合チェック（format + lint）                  |
| `check:format`     | フォーマットチェック集約（書き込みなし）              |
| `check:lint`       | lint チェック集約                                     |
| `check:lint:quick` | lint チェック集約（lint:links 除外）                  |

### Format

`format.toml`, `integration.toml` で定義。

| タスク                          | 説明                                             |
| ------------------------------- | ------------------------------------------------ |
| `format`                        | 全フォーマット（書き込みあり）                   |
| `format:biome`                  | JS/TS/JSON フォーマット + Biome lint 修正        |
| `format:prettier`               | Prettier フォーマット                            |
| `format:markdown`               | Markdown フォーマット（markdownlint + prettier） |
| `format:yaml`                   | YAML フォーマット（prettier）                    |
| `format:lua`                    | Lua フォーマット（stylua）                       |
| `format:shell`                  | シェルスクリプトフォーマット（shfmt / beautysh） |
| `format:toml`                   | TOML フォーマット（taplo）                       |
| `format:python`                 | Python フォーマット（ruff）                      |
| `format:docs`                   | ドキュメント完全検証とフォーマット               |
| `format:markdown:bold-headings` | 太字見出しを `###` へ変換                        |

書き込みなしのチェックは `:check` バリアントを使う（例: `format:biome:check`, `format:markdown:check`）。
Markdown のタスク名は `markdown` を使い、`format:md:check` は定義していない。

### Lint

`lint.toml`, `integration.toml` で定義。

| タスク            | 説明                                                    |
| ----------------- | ------------------------------------------------------- |
| `lint`            | 全 lint（lint:links 含む、低速）                        |
| `lint:quick`      | 軽量 lint（lint:links 除外）                            |
| `lint:biome`      | JS/TS/JSON チェック（biome）                            |
| `lint:markdown`   | Markdown チェック（markdownlint）                       |
| `lint:yaml`       | YAML チェック（yamllint）                               |
| `lint:lua`        | Lua チェック（luacheck）                                |
| `lint:shell`      | シェルスクリプトチェック（shellcheck）                  |
| `lint:python`     | Python チェック（ruff）                                 |
| `lint:dockerfile` | Dockerfile チェック（hadolint）                         |
| `lint:links`      | Markdown リンクチェック（時間がかかるため個別実行推奨） |
| `lint:actions`    | GitHub Actions チェック（actionlint）                   |

### Test

`test.toml` で定義。

| タスク           | 説明                                               |
| ---------------- | -------------------------------------------------- |
| `test`           | テスト集約（test:lua + test:ts）                   |
| `test:lua`       | Lua テスト（busted）                               |
| `test:ts`        | TypeScript ユニットテスト                          |
| `test:lua:watch` | Lua テスト監視モード（ファイル変更時に自動再実行） |

### Dotfiles 配布（mise bootstrap）

Home Manager は撤去済み。dotfiles 配布・launchd agents は mise bootstrap が担当する。

| コマンド                | 説明                                                     |
| ----------------------- | -------------------------------------------------------- |
| `mise bootstrap --yes`  | マシン全体を収束（packages/dotfiles/launchd/tools/task） |
| `mise dotfiles apply`   | dotfiles のみ適用                                        |
| `mise dotfiles status`  | 配布状態の確認                                           |
| `mise bootstrap status` | bootstrap 全体の状態確認                                 |
| `mise run bootstrap`    | headroom venv (macOS) と tmux plugins 初期化             |

定義は `mise/config.toml`（OS 非依存）と `mise/config.default.toml`（macOS 専用）にある。

### APM Workspace

APM の日常運用は `~/.apm` から行う。`.config` 側に APM 専用 `mise` task は置かない。

代表例:

- `cd ~/.apm && mise install`
- `cd ~/.apm && mise run check`
- `cd ~/.apm && mise run deploy`
- `cd ~/.apm && mise run doctor`
- `cd ~/.apm && mise run prepare:catalog`
- `cd ~/.apm && mise run install:catalog`

詳細は [docs/tools/apm-workspace.md](apm-workspace.md) を参照。

### Update

`updates.toml` で定義。

| タスク                  | 説明                                                              |
| ----------------------- | ----------------------------------------------------------------- |
| `update`                | pull 後に OS / mise の依存関係を更新（破壊的 Git 更新は含まない） |
| `pull`                  | 現在のリポジトリを fast-forward pull                              |
| `update:brew`           | Homebrew パッケージ更新（formula のみ）                           |
| `update:mise`           | mise 管理ツールを更新                                             |
| `update:apt`            | APT パッケージ更新（Ubuntu/Debian）                               |
| `update:submodules`     | Git サブモジュール更新（変更を破棄するため個別実行）              |
| `update:external-repos` | 外部 Git リポジトリ更新（強制リセット、個別実行）                 |

### Env

`env.toml` で定義。

| タスク        | 説明                                                   |
| ------------- | ------------------------------------------------------ |
| `env:detect`  | 現在の環境タイプを検出（CI/Pi/Default）                |
| `env:encrypt` | 環境変数ファイルを暗号化（dotenvx）                    |
| `env:decrypt` | 環境変数ファイルを復号化（dotenvx）                    |
| `setup-env`   | .env を .env.local に復号化（mise hooks から自動実行） |

### Brewfile

`brewfile.toml` で定義。

| タスク             | 説明                                                   |
| ------------------ | ------------------------------------------------------ |
| `brewfile:restore` | Brewfile からパッケージをインストール（新規 Mac 対応） |

formulae の宣言管理は `mise bootstrap packages`（`mise/config.macos.toml` の `[bootstrap.packages]`）へ移行済み。Brewfile は casks / mas / vscode と bootstrap 非対応の例外のみを保持する。dump による再生成（旧 `brewfile:backup`）は bootstrap 宣言と両立しないため廃止。

### 統合・診断

`integration.toml` で定義。

| タスク   | 説明                                             |
| -------- | ------------------------------------------------ |
| `setup`  | 初回セットアップ（mise install + 依存確認）      |
| `doctor` | 環境診断（mise doctor + インストール済みツール） |

### APM / global skill 変更時の確認

`.config` 側は APM の入口を示すだけで、global skill / agent / command の日常運用は `~/.apm` が正本です。
APM 配布に関わる変更をした場合は、`.config` の `mise run ci` だけで完了扱いにせず、必要に応じて以下を `~/.apm` 側で確認します。

```bash
cd ~/.apm
mise run validate:catalog
mise run doctor
```
