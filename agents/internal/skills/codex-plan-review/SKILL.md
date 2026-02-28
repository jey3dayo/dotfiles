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

```bash
codex exec --sandbox read-only --full-auto "
Review the following implementation plan. Identify:
1. Potential risks and failure points
2. Missing steps or edge cases
3. Technical concerns or anti-patterns
4. Scope creep or unnecessary complexity

Be specific and concise. If the plan looks solid, say so.

---
<plan content here>
" 2>/dev/null
```

### 4. Report Results

- Critical issues found → Present specific findings and suggestions, confirm whether to address them
- Minor concerns only → Share as notes; implementation can proceed
- No issues → Confirm the plan is ready to implement
