---
name: docs-write
description: このリポジトリのMarkdownドキュメント作成・更新・整形の手順を提供する。`mise` の `docs:fix` / `docs:format` / `format` タスク運用、`.prettierrc.json` と `.markdownlint-cli2.yaml` のルール準拠が必要なときに使用する。
---

# Docs Write

## 概要

このスキルは、Markdownドキュメントの書き方とフォーマット手順を統一する。

## クイックスタート

1. 対象ファイルを確認し、既存ファイルの更新を優先する。
2. 文章と構成を整える（見出し、箇条書き、コードブロック）。
3. `mise run format` で `docs:fix` → `docs:format` を適用する。

## 書き方ガイド

- 既存の文体・言語に合わせて書く。
- 見出しは `#` から順序を守って構成する。
- 手順は番号付き、要点は箇条書きで簡潔に書く。
- コマンドやパスはバッククォートで囲む。複数行はコードブロックを使う。
- 新規ドキュメント追加は依頼がある場合のみにする（既存更新を優先する）。

## フォーマット基準

- Prettier: `.prettierrc.json` の設定に従って整形する。手動の改行調整は控える。
- markdownlint: `.markdownlint-cli2.yaml` の設定に従ってチェックする。
  - MD013 の行長は 600 を許容する。
  - MD040 と MD024 は無効化されている。

## フォーマット/検証フロー

### 標準

```bash
mise run format
```

`format` は `docs:fix` と `docs:format` を順に実行する。

### 個別実行

```bash
mise run docs:fix
mise run docs:format
```

### 追加チェック（必要時）

```bash
mise run lint
```

`lint` は `docs:lint` と `docs:links` を実行する。

## mise タスクの実体

- `docs:format`: `prettier --write --cache --log-level warn '**/*.md'`
- `docs:fix`: `npx markdownlint-cli2 --fix '**/*.md' '#node_modules'`

## 参照先

- `mise.toml` — タスク定義
- `.prettierrc.json` — Prettier設定
- `.markdownlint-cli2.yaml` — markdownlint設定
- `.kiro/steering/tech.md` — ドキュメント運用方針
