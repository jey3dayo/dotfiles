---
name: codex-code-review
description: >-
  Review code changes using Codex. Use when user asks to review code,
  check code quality, or wants feedback before committing or creating
  a pull request.
  Triggers: "コードレビュー", "code review with codex", "codex でレビュー",
  "変更をチェック", "review my changes", "review code".
allowed-tools: Bash(codex:*), Bash(jq:*), Bash(git:*), Read, Edit, Grep, Glob
---

# Codex Code Review

Review code changes with Codex and apply fixes if issues are found.

## Workflow

### 1. Detect Changes and Determine Mode

```bash
git status --porcelain
```

- Output present → uncommitted changes mode
- No output → branch diff mode (diff against default branch)

### 2. Run Review

#### Uncommitted Changes Mode

```bash
codex exec --model gpt-5.3-codex --sandbox read-only --full-auto "
Review the following uncommitted changes. Identify:
1. Bugs or logic errors
2. Security concerns
3. Type safety issues
4. Code style or readability problems
5. Missing error handling

Be specific and concise. Reference file paths and line numbers.
Output JSON: {\"issues\": [{\"file\": \"...\", \"line\": N, \"severity\": \"critical|warning|info\", \"message\": \"...\"}], \"summary\": \"...\"}

---
$(git diff HEAD)
$(git diff --cached)
" 2>/dev/null
```

#### Branch Diff Mode

```bash
BASE=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||'); BASE=${BASE:-main}
codex exec --model gpt-5.3-codex --sandbox read-only --full-auto "
Review the following branch changes against ${BASE}. Identify:
1. Bugs or logic errors
2. Security concerns
3. Type safety issues
4. Code style or readability problems
5. Missing error handling

Be specific and concise. Reference file paths and line numbers.
Output JSON: {\"issues\": [{\"file\": \"...\", \"line\": N, \"severity\": \"critical|warning|info\", \"message\": \"...\"}], \"summary\": \"...\"}

---
$(git diff ${BASE}...HEAD)
" 2>/dev/null
```

### 3. Extract Results

```bash
# Extract issues from JSON output
echo '<codex output>' | jq '.issues'
```

### 4. Evaluate and Respond

- Critical issues found → Read the affected file and apply fixes with Edit
- Warnings only → Share with user and confirm whether to fix
- Info only / no issues → Report review complete

### 5. Re-review After Fixes

If fixes were applied, return to step 1 and re-run the review.
Repeat until zero issues remain (max 3 iterations).
If unresolved after 3 attempts, report remaining issues and defer to the user.
