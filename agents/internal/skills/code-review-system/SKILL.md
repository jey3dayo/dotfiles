---
name: code-review-system
description: |
  [What] GitHub PR workflow orchestrator — CI diagnosis, review comment handling, and auto-fix.
  [When] Use when: CI fails, PR has review comments to address, or need automated PR fixes.
  [Keywords] CI fix, PR review, fix ci, fix pr, address comments, GitHub Actions, PR workflow
  [Note] Always responds in Japanese.
argument-hint: "--ci [PR#] | --comments | --fix [PR#] | --all"
disable-model-invocation: true
user-invocable: true
allowed-tools: Task, Bash(gh:*), Read, Grep, Glob
---

# Code Review System — PR Workflow Orchestrator

Integrated workflow for GitHub PR management. Orchestrates CI diagnosis, review comment handling, and automated fixes using specialized skills.

## Important Notes

### No-Signature Policy (CRITICAL)

- NEVER add `Co-authored-by: Claude` to commits
- NEVER use emojis in commits, PRs, issues, or git content
- NEVER add "Generated with Claude Code" signatures

## Modes

### 1. CI Diagnosis (`--ci`)

Diagnose and fix GitHub Actions CI failures.

- Retrieves CI logs via `gh` CLI
- Classifies failures (lint, test, build, type-check)
- Creates fix plan with priority ordering
- Delegates to `gh-fix-ci` skill for log retrieval and analysis

```bash
/code-review-system --ci           # Diagnose PR on current branch
/code-review-system --ci 123       # Specify PR number
/code-review-system --ci --dry-run # Diagnose only (no fix)
```

### 2. Comment Handling (`--comments`)

Address review comments on the current PR.

- Retrieves PR review comments via `gh` CLI
- Classifies by source (human, CodeRabbit, bots)
- Prioritizes by severity
- Delegates to `gh-address-comments` skill

```bash
/code-review-system --comments              # Address all comments
/code-review-system --comments --bot coderabbitai  # Specific bot only
```

### 3. Auto-Fix (`--fix`)

Automatically fix PR review comments with priority ordering.

- Fetches comments via `gh-address-comments` skill (`fetch_comments.py`)
- Classifies comments as Critical/High/Major/Minor (self)
- Applies fixes in priority order
- Validates each fix with `mise run ci:quick`
- Rolls back on failure

```bash
/code-review-system --fix              # Fix PR on current branch
/code-review-system --fix 123          # Specify PR number
/code-review-system --fix --priority critical  # Critical only
/code-review-system --fix --dry-run    # Classify only, no fix
```

### 4. Integrated Flow (`--all`)

Run CI diagnosis + comment handling + auto-fix in sequence.

```bash
/code-review-system --all              # Full flow for current branch PR
/code-review-system --all 123          # Specify PR number
/code-review-system --all --dry-run    # Diagnose/classify only
```

### External Review Delegation

Delegate review to external models (model-agnostic):

```bash
/code-review-system --ci --external codex   # Use Codex for analysis
/code-review-system --ci --external gemini  # Use Gemini for analysis
```

## Options

### Mode Selection

- `--ci [PR#]`: CI diagnosis mode
- `--comments`: Review comment handling mode
- `--fix [PR#]`: Auto-fix mode
- `--all [PR#]`: Integrated flow (CI + comments + fix)

### Filtering

- `--priority <level>`: Fix only this priority (critical/high/major/minor)
- `--bot <name>`: Only comments from specific bot (e.g., coderabbitai)
- `--category <cat>`: Specific category only (security/bug/style/etc)

### Behavior

- `--dry-run`: Diagnose/classify only, no modifications
- `--external <model>`: Delegate to external model (codex/gemini)

## Execution Flow

```
PR # detection (current branch or explicit)
    |
    v
+-- --ci ---------> gh-fix-ci skill
|                   -> Fetch CI logs
|                   -> Classify failures
|                   -> Create fix plan
|                   -> Apply fixes
|
+-- --comments ---> gh-address-comments skill
|                   -> Fetch review comments
|                   -> Classify by source/severity
|                   -> Address each comment
|
+-- --fix --------> gh-address-comments (fetch_comments.py)
|                   -> Fetch all PR comments as JSON
|                   -> Classify priority (self)
|                   -> Apply fixes: Critical -> High -> Major -> Minor
|                   -> Validate each fix (mise run ci:quick)
|                   -> Rollback on failure
|
+-- --all --------> Run all above in sequence
    |
    v
Quality verification (lint/test/build)
    |
    v
Report results (Japanese)
```

## Skill Dependencies

| Skill                 | Role                          |
| --------------------- | ----------------------------- |
| `gh-fix-ci`           | CI log retrieval and analysis |
| `gh-address-comments` | PR comment fetch via GraphQL  |

## Troubleshooting

### PR not found

```bash
# Check if PR exists for current branch
gh pr list --head $(git branch --show-current)

# Specify PR number explicitly
/code-review-system --ci 123
```

### CI logs not accessible

```bash
# Check gh CLI auth
gh auth status

# Refresh permissions
gh auth refresh -s repo
```

## Related

- `code-review` — Local code review (detailed/simple modes, star ratings)
- `gh-fix-ci` — CI failure diagnosis helper
- `gh-address-comments` — Review comment handler

---

### Goal
