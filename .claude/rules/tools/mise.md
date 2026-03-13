---
paths: mise/**/*, .mise.toml, scripts/setup-mise-env.sh, zsh/.zshenv, bash/.bashrc
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
- その他: `config.default.toml`
- 環境変数 `MISE_CONFIG_FILE` は Home Manager の `nix/env-detect.nix` が自動設定

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

## タスク使い分け

| コマンド             | 用途                                      |
| -------------------- | ----------------------------------------- |
| `mise run ci`        | ローカル検証のみ（書き込みなし）          |
| `mise run ci:full`   | 検証 + デプロイ（GitHub Actions 同等）    |
| `mise run hm:deploy` | Home Manager デプロイ（バックアップ付き） |
| `mise run hm:switch` | ローカル開発用 HM 適用                    |

## ツール管理方針

- mise で管理: 開発ツール・フォーマッター・Linter・npm/pipx パッケージ・言語ランタイム
- Homebrew で管理: Neovim 依存関係・システムライブラリ・GUI アプリ
- `npm install -g`, `pnpm add -g`, `bun add -g`, `pip install --user` は使わない
- mise 管理ツールに `command -v` チェックを書かない（shim が自動解決）

詳細は [docs/tools/mise.md](../../../docs/tools/mise.md) を参照。
