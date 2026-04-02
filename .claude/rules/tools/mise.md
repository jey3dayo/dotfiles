---
paths: mise/**/*, .mise.toml, scripts/setup-mise-env.sh, zsh/.zshenv, bash/.bashrc, docs/tools/mise.md
source: docs/tools/mise.md
---

# Mise Rules

Purpose: unified tool version management with mise-en-place.
Detailed Reference: [docs/tools/mise.md](../../../docs/tools/mise.md)

## 設定ファイル優先度

`directory-local (.mise.toml)` > `MISE_CONFIG_FILE` > `user config` > `global defaults`

| ファイル                   | 対象環境         | 特徴                                    |
| -------------------------- | ---------------- | --------------------------------------- |
| `mise/config.toml`         | 共通             | 設定のみ（ツール定義なし）              |
| `mise/config.default.toml` | macOS/Linux/WSL2 | フル構成（jobs=8）                      |
| `mise/config.windows.toml` | Windows          | Windows 用ツールセット（77 tools, jobs 未設定） |
| `mise/config.pi.toml`      | Raspberry Pi     | 最小構成（jobs=2、cargo 除外）          |
| `mise/config.ci.toml`      | CI/CD            | CI 必須ツールのみ（言語ランタイム除外） |

## pnpm バックエンド設定

`mise/config.toml` に設定済み:

```toml
[settings]
npm.package_manager = "pnpm"
```

`npm:` プレフィックスはそのまま使用可能（pnpm が透過的に処理）。

## 環境別設定の使い分け

- CI/CD: `CI=true` または `GITHUB_ACTIONS=true` → `config.ci.toml`
- Raspberry Pi: ARM + `/sys/firmware/devicetree/base/model` に "Raspberry Pi" → `config.pi.toml`
- Default: macOS/Linux/WSL2 など → `config.default.toml`
- Windows: `config.windows.toml` は存在するが、現状 `nix/env-detect.nix` の自動判定対象ではない
- `MISE_CONFIG_FILE` の Home Manager 自動設定は現状 CI / Pi / Default に限定される

## 主要コマンド

```bash
mise install          # 全ツールインストール
mise upgrade          # 全ツール更新
mise prune            # 未使用バージョン削除
mise doctor           # ヘルスチェック
mise ls               # インストール済み一覧
mise outdated         # 更新確認
mise tasks            # タスク一覧
```

## タスクグループ早見表

| グループ     | 主要タスク                                          | 用途                                    |
| ------------ | --------------------------------------------------- | --------------------------------------- |
| CI / 検証    | `ci:quick`, `ci`, `ci:full`, `ci:nix`               | ローカル CI・GitHub Actions 同等実行    |
| Format       | `format`, `format:biome`, `format:markdown`         | 自動フォーマット（書き込みあり）        |
| Lint         | `lint`, `lint:quick`, `lint:links`                  | 静的解析・構文チェック（書き込みなし）  |
| Test         | `test`, `test:lua`, `test:ts`                       | Lua(busted) / TypeScript ユニットテスト |
| Home Manager | `hm:deploy`, `hm:switch`, `hm:check`, `hm:rollback` | HM 適用・検証・ロールバック             |
| Skills       | `skills:add`, `skills:upgrade`, `skills:validate`   | Agent skills 追加・更新・検証           |
| Update       | `update`, `update:brew`, `update:apt`               | 依存関係一括更新                        |
| Env          | `env:detect`, `env:encrypt`, `env:decrypt`          | 環境検出・dotenvx 管理                  |
| Brewfile     | `brewfile:backup`, `brewfile:restore`               | Brewfile バックアップ・新規 Mac 復元    |
| 診断         | `setup`, `doctor`                                   | 初回セットアップ・環境診断              |

全タスク詳細は [docs/tools/mise-tasks.md](../../../docs/tools/mise-tasks.md) を参照。

## ツール管理方針

- mise で管理: 開発ツール・フォーマッター・Linter・npm/pipx パッケージ・言語ランタイム
- Homebrew で管理: Neovim 依存関係・システムライブラリ・GUI アプリ
- `npm install -g`, `pnpm add -g`, `bun add -g`, `pip install --user` は使わない
- mise 管理ツールに `command -v` チェックを書かない（shim が自動解決）

詳細は [docs/tools/mise.md](../../../docs/tools/mise.md) を参照。
