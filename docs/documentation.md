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
timestamp: 2026-06-29
audience: developer
owner: dotfiles
---

# Documentation Governance

最終更新: 2026-06-29
対象: 開発者
タグ: `category/documentation`, `layer/support`, `environment/cross-platform`, `audience/developer`

この文書は、この repo のドキュメント運用ルールの正本です。読む目的は 1 つで、「どこに何を書くか」を迷わないようにすることです。

## 役割分担

- `README.md`: リポジトリ全体の入口。概要と主要リンクだけを書く
- `docs/README.md`: `docs/` 全体のナビゲーション。詳細手順は書かない
- `llms.md`: LLM/AI エージェント向けの軽量入口。正本と参照順だけを案内する
- `docs/`: 人間向けの詳細手順と運用の正本
- `.claude/rules/`: `docs/` の要約と制約だけを置く

## 正本マップ

| トピック                                 | 正本                      |
| ---------------------------------------- | ------------------------- |
| 導入・初期セットアップ                   | `docs/setup.md`           |
| パフォーマンス実測・改善履歴             | `docs/performance.md`     |
| 定期運用・日常メンテナンス・横断トラブル | `docs/tools/workflows.md` |
| セキュリティ運用                         | `docs/security.md`        |
| ツール別詳細                             | `docs/tools/*.md`         |
| ドキュメント運用ルール                   | `docs/documentation.md`   |

`README.md`、`docs/README.md`、`TOOLS.md`、`llms.md` はナビゲーション文書であり、正本の代替にしません。

## 更新ルール

1. まず対応する `docs/` の正本を更新する
2. 必要な場合だけ `README.md`、`docs/README.md`、`llms.md`、`.claude/rules/` の案内を同期する
3. 同じ手順や数値を複数の入口文書に再掲しない

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

## 重複防止

- セットアップ手順は `docs/setup.md` だけで更新する
- パフォーマンス数値は `docs/performance.md` だけで更新する
- 運用手順と横断トラブルは `docs/tools/workflows.md` に集約する
- ツール固有の詳細は対応する `docs/tools/*.md` に集約する
- `.claude/rules/` は要約だけに留める

## 迷ったら

1. `AGENTS.md`
2. この文書
3. 対応する `docs/` の正本

この文書も長くなり始めたら、説明を足すのではなく削って入口性を保ちます。
