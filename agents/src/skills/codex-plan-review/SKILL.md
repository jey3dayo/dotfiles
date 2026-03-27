---
name: codex-plan-review
description: >-
  Review implementation plan files with Codex to identify potential risks,
  missing steps, and technical concerns. Use when you want a quality check
  before starting implementation.
  Triggers: "プランをレビュー", "plan review", "実装前にチェック",
  "codex でレビュー", "プランの確認", "review the plan".
allowed-tools: Bash(codex:*), Bash(ls:*), Read
---

# Codex Plan Review

Review the latest plan file in `~/.claude/plans/` with Codex and report any issues.

## Workflow

### 1. Identify the Latest Plan File

```bash
ls -t ~/.claude/plans/*.md | head -1
```

### 2. Read the Plan Content

Read the entire plan file using the Read tool.

### 3. Run Review with Codex

> **Resume-first**: 先行する Codex セッション（codex-system での設計相談等）があれば
> `resume --last` でコンテキストを引き継ぐ。セッションがなければ新規実行にフォールバック。
>
> **Resume 制約**: resume 時は `--sandbox` 指定不可（セッション元から継承）。`--full-auto`, `--all` 等は指定可能。プロンプトは stdin 経由で渡す。
>
> **Error handling**: codex が非ゼロで終了した場合（resume / fresh exec 両方失敗）、
> エラーを報告し、手動レビューにフォールバックする。

```bash
REVIEW_PROMPT="
Review the following implementation plan. Identify:
1. Potential risks and failure points
2. Missing steps or edge cases
3. Technical concerns or anti-patterns
4. Scope creep or unnecessary complexity

Be specific and concise. If the plan looks solid, say so.

---
<plan content here>
"

echo "$REVIEW_PROMPT" | codex exec resume --last 2>/dev/null || \
codex exec --sandbox read-only "$REVIEW_PROMPT" 2>/dev/null
```

### 4. Report Results

- Critical issues found → Present specific findings and suggestions, confirm whether to address them
- Minor concerns only → Share as notes; implementation can proceed
- No issues → Confirm the plan is ready to implement
