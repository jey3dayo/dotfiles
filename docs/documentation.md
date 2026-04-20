# Documentation Governance

最終更新: 2026-04-20
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

`docs/**/*.md` は先頭に次を持ちます。

- `最終更新`
- `対象`
- `タグ`

ルール:

- 日付形式は `YYYY-MM-DD`
- タグはバッククォートで囲み、カンマ区切り
- 少なくとも `category/` と `layer/` を 1 つずつ含める
- 必要に応じて `environment/`, `audience/`, `tool/` を追加する

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
