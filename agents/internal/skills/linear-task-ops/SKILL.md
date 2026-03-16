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

## Guardrails

- Resolve team states first; state names differ by team.
- Prefer one consolidated update/comment over many tiny writes.
- Never print API tokens in logs or chat.
- Validate changes by re-listing the issue/team after updates.
