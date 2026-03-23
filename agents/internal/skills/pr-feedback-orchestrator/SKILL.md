---
name: pr-feedback-orchestrator
description: |
  [What] GitHub PR feedback orchestrator — ingest CI failures, review comments, and bot feedback, then coordinate fixes and verification.
  [When] Use when: CI fails, PR has review comments to address, or need automated PR feedback fixes.
  [Keywords] PR feedback, CI fix, PR review, fix ci, fix pr, address comments, GitHub Actions, PR workflow
  [Note] Always responds in Japanese.
argument-hint: "--ci [PR#] | --comments | --fix [PR#] | --all"
disable-model-invocation: true
user-invocable: true
allowed-tools: Task, Bash(gh:*, python3:*, git:*, mise:*), Read, Grep, Glob, Edit
---

# PR Feedback Orchestrator

Integrated workflow for GitHub PR management. Ingests CI failures and PR feedback, then orchestrates fixes and verification using specialized skills.

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
/pr-feedback-orchestrator --ci           # Diagnose PR on current branch
/pr-feedback-orchestrator --ci 123       # Specify PR number
/pr-feedback-orchestrator --ci --dry-run # Diagnose only (no fix)
```

### 2. Comment Handling (`--comments`)

Address review comments on the current PR.

- Retrieves PR review comments via `gh` CLI
- Classifies by source (human, CodeRabbit, bots)
- Prioritizes by severity
- Delegates to `gh-address-comments` skill

```bash
/pr-feedback-orchestrator --comments              # Address all comments
/pr-feedback-orchestrator --comments --bot coderabbitai  # Specific bot only
```

### 3. Auto-Fix (`--fix`)

Automatically fix PR review comments with priority ordering.

- Fetches comments via `gh-address-comments` skill (`fetch_comments.py`)
- Classifies comments as Critical/High/Major/Minor (self)
- Applies fixes in priority order
- Validates each fix with `mise run ci:quick`
- Rolls back on failure

```bash
/pr-feedback-orchestrator --fix              # Fix PR on current branch
/pr-feedback-orchestrator --fix 123          # Specify PR number
/pr-feedback-orchestrator --fix --priority critical  # Critical only
/pr-feedback-orchestrator --fix --dry-run    # Classify only, no fix
```

### 4. Integrated Flow (`--all`)

Run CI diagnosis + comment handling + auto-fix in sequence.

```bash
/pr-feedback-orchestrator --all              # Full flow for current branch PR
/pr-feedback-orchestrator --all 123          # Specify PR number
/pr-feedback-orchestrator --all --dry-run    # Diagnose/classify only
```

### External Review Delegation

Delegate review to external models (model-agnostic):

```bash
/pr-feedback-orchestrator --ci --external codex   # Use Codex for analysis
/pr-feedback-orchestrator --ci --external gemini  # Use Gemini for analysis
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
|                   -> Stash rollback on failure (preserves prior fixes)
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
/pr-feedback-orchestrator --ci 123
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
