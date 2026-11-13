---
type: policy
title: Documentation Governance
description: dotfiles repo のドキュメント配置、metadata、SSOT 境界を定義する正本
resource: docs/documentation.md
tags:
  - category/documentation
  - layer/support
  - environment/cross-platform
  - audience/developer
timestamp: 2026-11-13
audience: developer
owner: dotfiles
---

# Documentation Governance

最終更新: 2026-11-13
対象: 開発者
タグ: `category/documentation`, `layer/support`, `environment/cross-platform`, `audience/developer`

この文書はドキュメントの配置と更新ルールの正本です。

## 役割分担

- `AGENTS.md`: リポジトリ固有の AI 協働ルールと docs の参照先
- `README.md`: リポジトリの概要と主要リンク
- `docs/README.md`: `docs/` のナビゲーション。詳細手順は書かない
- `docs/`: 人間向けの詳細手順と運用の正本
- `.claude/rules/`: `docs/` の要約と制約だけを置く

## 正本マップ

| トピック                                 | 正本                                                                 |
| ---------------------------------------- | -------------------------------------------------------------------- |
| 導入・初期セットアップ                   | `docs/setup.md`                                                      |
| 起動時間の実測値                         | 各ツールの `docs/tools/*.md`（`zsh.md` / `nvim.md` の検証節）        |
| 定期運用・日常メンテナンス・横断トラブル | `docs/tools/workflows.md`                                            |
| セキュリティ運用                         | `docs/security.md`                                                   |
| ツール別詳細                             | `docs/tools/*.md`                                                    |
| ツールのバージョン・pin                  | `mise/*.toml`（docs にはバージョン番号を書かず、pin の理由だけ書く） |
| ドキュメント運用ルール                   | `docs/documentation.md`                                              |

`README.md` と `docs/README.md` は案内だけを担い、各トピックの正本にある詳細手順や数値は再掲しません。AI エージェントは `AGENTS.md` からリポジトリ固有ルールを読み、作業に応じて該当する docs を参照します。

## 更新ルール

1. まず対応する `docs/` の正本を更新する
2. 必要な場合だけ `AGENTS.md`、`README.md`、`docs/README.md`、`.claude/rules/` の案内を同期する
3. 同じ手順や数値を複数の入口文書に再掲しない。ツールのバージョン番号は `mise/*.toml` だけに書き、docs には固定理由を書く

## メタデータ規約

新規または大きく更新する `docs/**/*.md` は、OKF（Open Knowledge Format）互換の YAML frontmatter を canonical metadata として使います。

```yaml
---
type: reference
title: Documentation Governance
description: この文書の目的を1文で書く
resource: docs/documentation.md
tags:
  - category/documentation
  - layer/support
timestamp: 2026-06-29
audience: developer
owner: dotfiles
---
```

必須:

- `type`

推奨:

- `title`
- `description`
- `resource`
- `tags`
- `timestamp`
- `audience`
- `owner`

OKF 互換 metadata の扱い:

- `timestamp` は従来の `最終更新` と同じ意味で扱う
- `tags` は従来の `タグ` と同じ意味で扱う
- `tags` には少なくとも `category/` と `layer/` を 1 つずつ含める
- `resource` は原則として repo ルートからの相対パスにする
- `type` は文書の役割に応じて `reference`, `guide`, `runbook`, `index`, `policy` などの短い英小文字を使う

既存 docs の互換ルール:

`docs/**/*.md` は移行が完了するまで、先頭付近の legacy metadata block も有効です。

- `最終更新`
- `対象`
- `タグ`

legacy metadata のルール:

- 日付形式は `YYYY-MM-DD`
- タグはバッククォートで囲み、カンマ区切り
- 少なくとも `category/` と `layer/` を 1 つずつ含める
- 必要に応じて `environment/`, `audience/`, `tool/` を追加する

frontmatter と legacy metadata の両方がある場合は、frontmatter を正本とし、値が矛盾する場合だけ修正対象にします。

`docs/README.md` のようなナビゲーション文書は `type: index` として扱い、詳細手順を増やさずリンクの入口性を保ちます。

タグ語彙の参考は [`.claude/doc-standards/references/tag-taxonomy.md`](../.claude/doc-standards/references/tag-taxonomy.md) を使います。

## 迷ったら

1. `AGENTS.md`
2. この文書
3. 対応する `docs/` の正本

この文書も長くなり始めたら、説明を足すのではなく削って入口性を保ちます。
