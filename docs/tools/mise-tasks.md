# Mise Task Catalog

最終更新: 2026-04-19
対象: 開発者
タグ: `category/configuration`, `tool/mise`, `layer/tool`, `environment/cross-platform`, `audience/developer`

Claude Rules: [.claude/rules/tools/mise.md](../../.claude/rules/tools/mise.md)
親ドキュメント: [Mise Reference](mise.md)

全タスク一覧（`mise tasks` でも確認可能）。

### CI / 検証

`ci.toml`, `integration.toml` で定義。

| タスク             | 説明                                                  |
| ------------------ | ----------------------------------------------------- |
| `ci:quick`         | 軽量チェック（format + lint のみ、~3-5s、hooks 向け） |
| `ci`               | 全 CI チェック（検証のみ、書き込みなし）              |
| `ci:full`          | CI チェック + デプロイ + 検証（GitHub Actions 同等）  |
| `ci:nix`           | Nix 固有の深い検証（nix:check + nix:build:bundle）    |
| `ci:gitleaks`      | gitleaks による secret スキャン                       |
| `ci:install`       | CI 必要ツールをインストール（luacheck, busted）       |
| `nix:check`        | `nix flake check` を実行                              |
| `nix:build:bundle` | `nix build .#bundle` を実行                           |
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

上記各タスクに対応する `:check` バリアント（書き込みなし）あり（例: `format:biome:check`）。

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

### Home Manager

`home-manager.toml` で定義。

| タスク           | 説明                                     |
| ---------------- | ---------------------------------------- |
| `hm:deploy`      | HM 適用（CI/自動化用、バックアップ付き） |
| `hm:switch`      | HM 適用（ローカル開発用）                |
| `hm:check`       | 設定検証（ビルドのみ、適用なし）         |
| `hm:rollback`    | 前の世代にロールバック                   |
| `hm:clean`       | 古い世代を削除（30 日以上前）            |
| `hm:generations` | 世代一覧を表示                           |
| `hm:news`        | HM news を表示                           |

詳細は [docs/tools/home-manager.md](home-manager.md) を参照。

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

| タスク                  | 説明                                      |
| ----------------------- | ----------------------------------------- |
| `update`                | 全依存関係更新（brew + apt + submodules） |
| `update:brew`           | Homebrew パッケージ更新（formula のみ）   |
| `update:apt`            | APT パッケージ更新（Ubuntu/Debian）       |
| `update:submodules`     | Git サブモジュール更新（最新 tip）        |
| `update:external-repos` | 外部 Git リポジトリ更新（強制リセット）   |

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
| `brewfile:backup`  | 現在のインストール状況を Brewfile に保存               |
| `brewfile:restore` | Brewfile からパッケージをインストール（新規 Mac 対応） |

### 統合・診断

`integration.toml` で定義。

| タスク   | 説明                                             |
| -------- | ------------------------------------------------ |
| `setup`  | 初回セットアップ（mise install + 依存確認）      |
| `doctor` | 環境診断（mise doctor + インストール済みツール） |
