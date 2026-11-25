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
timestamp: 2026-11-25
audience: developer
owner: dotfiles
---

# Documentation Governance

この文書は、本リポジトリにおけるドキュメントの配置、メタデータ規約、更新ルールの正本です。

## 役割分担

- `AGENTS.md`: リポジトリ固有の AI 協働ルールと `docs/` の参照先
- `README.md`: リポジトリの概要と主要リンク
- `docs/README.md`: `docs/` のナビゲーション（詳細手順は書かない）
- `docs/`: 人間向けの詳細手順と運用の正本
- `.claude/rules/`: `docs/` の要約と制約のみを置く

## 正本マップ

| トピック                                 | 正本                                                                   |
| ---------------------------------------- | ---------------------------------------------------------------------- |
| 導入・初期セットアップ                   | `docs/setup.md`                                                        |
| 起動時間の実測値                         | 各ツールの `docs/tools/*.md`（`zsh.md` / `nvim.md` の検証節）          |
| 定期運用・日常メンテナンス・横断トラブル | `docs/tools/workflows.md`                                              |
| セキュリティ運用                         | `docs/security.md`                                                     |
| ツール別詳細                             | `docs/tools/*.md`                                                      |
| ツールのバージョン・pin                  | `mise/*.toml`（docs にはバージョン番号を書かず、pin の理由だけを書く） |
| ドキュメント運用ルール                   | `docs/documentation.md`                                                |

`README.md` と `docs/README.md` は案内だけを担い、各トピックの正本にある詳細手順や数値は再掲しません。AI エージェントは `AGENTS.md` からリポジトリ固有ルールを読み、作業に応じて該当する `docs/` を参照します。

## 更新ルール

1. まず対応する `docs/` の正本を更新します。
2. 必要な場合のみ `AGENTS.md`、`README.md`、`docs/README.md`、`.claude/rules/` の案内を同期します。
3. 同じ手順や数値を複数の入口文書に再掲しません。ツールのバージョン番号は `mise/*.toml` のみに書き、`docs/` には固定理由を書きます。
4. 更新後は `mise run format:markdown:check` でフォーマット・lint（`replace-bold-headings.ts` / `markdownlint-cli2` / `prettier`）を通過させます。

## メタデータ規約

`docs/**/*.md` は、OKF（Open Knowledge Format）互換の YAML frontmatter を正本メタデータとして使用します。

```yaml
---
type: reference
title: Documentation Governance
description: この文書の目的を1文で書く
resource: docs/documentation.md
tags:
  - category/documentation
  - layer/support
timestamp: 2026-11-25
audience: developer
owner: dotfiles
---
```

### フィールド定義

- 必須: `type`
- 推奨: `title`, `description`, `resource`, `tags`, `timestamp`, `audience`, `owner`

### 記述ルール

- `timestamp` は `YYYY-MM-DD` 形式で更新日を記録します。
- `tags` は 3〜5 個を目安とし、少なくとも `category/` と `layer/` を 1 つずつ含めます。必要に応じて `environment/`、`audience/`、`tool/` を追加します。タグ語彙は [`.claude/doc-standards/references/tag-taxonomy.md`](../.claude/doc-standards/references/tag-taxonomy.md) を参照してください。
- `resource` は原則としてリポジトリルートからの相対パスにします。
- `type` は文書の役割に応じて `reference`, `guide`, `runbook`, `index`, `policy` などの短い英小文字を使います。
- `docs/README.md` のようなナビゲーション文書は `type: index` とし、詳細手順を増やさずリンクの入口性を保ちます。
- 旧形式の本文メタデータ（`最終更新` / `対象` / `タグ`）は YAML frontmatter へ移行済みです。両方残っている場合は frontmatter を正本とし、旧ブロックは削除します。

## 文体・記述スタイル

- 本文は原則として丁寧語（「です・ます」調）で統一します。
- 見出しや箇条書きラベルでの太字強調（`**見出し**`、`- **項目**:` など）は使わず、見出し記法（`##` / `###`）またはプレーンテキストを使います（`scripts/replace-bold-headings.ts` で自動検査されます）。
- Claude 向けルールへの案内が必要な文書は、冒頭付近に 1 行のリンクで簡潔に示します。

## 迷ったら

1. `AGENTS.md`
2. この文書
3. 対応する `docs/` の正本

この文書も長くなり始めたら、説明を足すのではなく削って入口性を保ちます。
