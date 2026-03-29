---
name: linear-task-ops
description: "Operate Linear issues through API-backed scripts: list teams/states/issues, create issues, update title/description/due date/state/priority, and add comments. Use when asked to create or edit Linear tasks, migrate task notes from Asana to Linear, or append transaction logs (date/payment/price) into an existing Linear issue."
---

# Linear Task Ops

Use `scripts/linear_task.py` for deterministic task operations instead of ad-hoc API calls.

## Labels / Tags

Use actual Linear labels as tag references. For current JEY team labels, read:

- `references/linear-labels-jey.md`

When label guidance is requested, prefer existing workspace conventions (`term:*`, `risk:*`, `Research`, `Bug`, `Improvement`, `Feature`) over inventing new tags.

## Quick Start

1. Ensure `LINEAR_API_KEY` (or `LINEAR_TOKEN`) is set in env.
2. Run from skill root or pass `LINEAR_ENV_FILE=/path/to/.env`.
3. Discover teams/states before writing:
   - `python3 scripts/linear_task.py teams`
   - `python3 scripts/linear_task.py states --team <TEAM_KEY>`

## Task Operations

### List issues

```bash
python3 scripts/linear_task.py list --team <TEAM_KEY> --limit 30
```

### Create issue

```bash
python3 scripts/linear_task.py create \
  --team <TEAM_KEY> \
  --title "d払いタッチ上限管理" \
  --description "集計メモ" \
  --due-date 2026-03-31
```

### Update issue fields

```bash
python3 scripts/linear_task.py update \
  --issue <ISSUE_ID> \
  --team <TEAM_KEY> \
  --state "In Progress" \
  --due-date 2026-03-31
```

### Add comment

```bash
python3 scripts/linear_task.py comment \
  --issue <ISSUE_ID> \
  --body "2026-03-14 | d払いタッチ | 4,435円"
```

## Asana → Linear Conversion Flow

1. Read source task data (title, notes, due date, status).
2. Create or locate target Linear issue.
3. Map fields using `references/asana-to-linear-mapping.md`.
4. Write payment logs as line-based records for easy aggregation.
5. If source includes a deadline in prose, also set Linear `dueDate`.

## Project Routing

タスク作成時に `--project` を省略した場合、以下のルールでプロジェクトを自動選択する。
判断に迷う場合や複数に該当する場合はユーザーに確認すること。

プロジェクト ID は `references/linear-projects-jey.md` を参照。

### 分類ルール

| プロジェクト | 対象ドメイン                                           | キーワード例                                                                    |
| ------------ | ------------------------------------------------------ | ------------------------------------------------------------------------------- |
| finance-ops  | お金・決済・サブスク・固定費・ポイ活・家計             | 支払い、請求、決済、サブスク、解約、ポイント、固定費、d払い、クレカ、引き落とし |
| labs         | 学習・調査・技術検証・研究・個人開発実験               | 調べる、検証、学習、試す、リサーチ、PoC、実験、ドキュメント読む                 |
| GBF          | グランブルーファンタジー全般                           | グラブル、GBF、古戦場、マグナ、召喚石、十天衆、エーテル                         |
| workbench    | 会社雑務・その他個人タスク（上記に当てはまらないもの） | 申請、会議、雑務、確認、連絡、その他                                            |

### 判断フロー

1. キーワードで明確に一致 → そのプロジェクトに作成
2. 複数に該当 / 判断できない → ユーザーに「finance-ops と workbench どちらですか？」と確認
3. どれにも当てはまらない → workbench をデフォルトとして提案し確認

## Guardrails

- Resolve team states first; state names differ by team.
- Prefer one consolidated update/comment over many tiny writes.
- Never print API tokens in logs or chat.
- Validate changes by re-listing the issue/team after updates.
