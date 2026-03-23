# Documentation Governance

最終更新: 2026-03-23
対象: 開発者
タグ: `category/documentation`, `layer/support`, `environment/cross-platform`, `audience/developer`

このリポジトリのドキュメント体系と更新ルールの正本です。`docs/` を人間向けの単一情報源とし、`.claude/rules/` はその要約と制約だけを保持します。

## ドキュメント階層

### `.kiro/steering/`

- AI セッションで常時読む高レベル文脈
- プロダクト概要、技術スタック、構造の把握を担当

### `docs/`

- 人間向けの詳細リファレンスと運用手順
- 各トピックの正本はここに置く

### `.claude/rules/`

- Claude 向けのコンパクトな制約と導線
- 詳細手順、長い表、履歴、メトリクスは持たない
- `docs/` の内容を圧縮して参照させるための層として扱う

## 正本マップ

| トピック                                 | 正本                      |
| ---------------------------------------- | ------------------------- |
| 導入・初期セットアップ                   | `docs/setup.md`           |
| パフォーマンス実測・改善履歴             | `docs/performance.md`     |
| 定期運用・日常メンテナンス・横断トラブル | `docs/tools/workflows.md` |
| セキュリティ運用                         | `docs/security.md`        |
| ツール別詳細                             | `docs/tools/*.md`         |
| ドキュメント体系そのもの                 | `docs/documentation.md`   |

`README.md`、`TOOLS.md`、`docs/README.md` はナビゲーションを担当し、正本の代替にならないようにします。

## メタデータ規約

`docs/` 配下のすべての Markdown ドキュメント（`docs/**/*.md`）は先頭に次の3項目を持ちます。

- `最終更新`
- `対象`
- `タグ`

ルール:

- 日付形式は `YYYY-MM-DD`
- タグはバッククォートで囲み、カンマ区切り
- タグは 3-5 個を推奨
- 少なくとも `category/` と `layer/` を 1 つずつ含める
- 必要に応じて `environment/`, `audience/`, `tool/` を追加する

## タグ体系

使用する接頭辞:

- `category/`
- `layer/`
- `environment/`
- `audience/`
- `tool/`

代表的な語彙は [`.claude/doc-standards/references/tag-taxonomy.md`](../.claude/doc-standards/references/tag-taxonomy.md) にまとめています。語彙を追加・変更するときは、まずこの文書の意図と整合するかを確認します。

## README とハブ文書の役割

- `README.md`: リポジトリの入口。概要と主要リンクのみ
- `TOOLS.md`: 管理対象ツールの棚卸し。詳細実装は `docs/tools/*.md` へ誘導
- `docs/README.md`: `docs/` 全体のナビゲーション。手順や長い説明を埋め込まない

ナビゲーション文書では、同じ手順や数値を再掲せず正本へリンクします。

## `.claude/rules/` の契約

`.claude/rules/**/*.md` は次の原則に従います。

- 常に簡潔に保つ
- 参照元が `docs/` にある場合は `source:` または `Sources:` で正本を明示する
- `paths:` はそのルールが効く対象だけに絞る
- 長い操作手順、履歴表、メトリクス表、詳細な例は `docs/` に置く
- ルールは「禁止事項」「判断基準」「読むべき正本」だけを残す

## 重複防止ルール

- セットアップ手順は `docs/setup.md` だけで更新する
- パフォーマンス数値は `docs/performance.md` だけで更新する
- 運用手順と横断トラブルは `docs/tools/workflows.md` に集約する
- ツール固有の詳細は対応する `docs/tools/*.md` に集約する
- `.claude/rules/` で同じ内容を再掲する場合は、要約に留める

## 更新フロー

1. まず `docs/` 側の正本を更新する
2. 必要な場合だけ `.claude/rules/` の要約を同期する
3. `最終更新` を更新する
4. 参照先リンクを確認する
5. 旧来の重複記述が残っていないか検索する

## サイズ目安

- 推奨: 500 行以下
- 注意: 1000 行超
- 2000 行超: 分割方針を立てる

巨大化した場合は、トピック別または責務別に分割し、親文書はナビゲーションへ寄せます。
