---
name: task-to-pr
description: |
  [What] End-to-end execution from task/request/Issue: task breakdown, worktree creation, implementation, checks, PR creation, CI monitoring and fixes.
  [When] Use when: You want to turn a task into a PR, run Issue handling E2E, or automatically fix CI failures.
  [Keywords] task, pr, worktree, ci, fix, github, issue, implementation
---

# Task to PR (v2: Context-aware)

## Purpose

Verify the task/request (or GitHub Issue) and execute E2E: worktree creation, implementation, local checks, PR creation, CI monitoring, and auto-fixing.

**v2 improvements**: Automatic detection of execution context (new task vs existing branch vs existing PR) and adaptive phase selection.

## Execution Context Detection

### Step 0: Detect Work Context (NEW)

**Before Phase 1, detect the current state**:

```bash
# 1. Current branch
current_branch=$(git branch --show-current)
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

# 2. Check if we're in a worktree
is_worktree=$([ $(git worktree list | wc -l) -gt 1 ] && echo "yes" || echo "no")

# 3. Check if PR exists for current branch
# Note: gh pr view without arguments checks the current branch's PR
pr_exists=$(gh pr view --json number 2>/dev/null && echo "yes" || echo "no")
```

**Decision matrix**:

| Context                   | Current Branch      | Worktree? | PR? | Start Phase | Notes                                    |
| ------------------------- | ------------------- | --------- | --- | ----------- | ---------------------------------------- |
| **New task**              | main/master/default | No        | No  | Phase 1     | Full workflow                            |
| **Resume implementation** | feature-branch      | No/Yes    | No  | Phase 1\*   | Skip worktree creation (Phase 2-3)       |
| **Resume validation**     | feature-branch      | No/Yes    | No  | Phase 4     | If code is implemented, start validation |
| **CI fix only**           | feature-branch      | No/Yes    | Yes | Phase 6     | PR exists, monitor/fix CI                |

\*Phase 1 still runs for context gathering and task decomposition, but Phase 2-3 (worktree creation) are skipped.

**User notification**:

```
[Context Detection]
✓ Branch: feat/user-auth (feature branch)
✓ Worktree: Yes
✓ PR: No

→ Detected context: Resume implementation
→ Starting from: Phase 1 (context gathering)
→ Will skip: Phase 2-3 (worktree creation - already in worktree)
```

### User Override

Users can force specific behavior:

```
/task-to-pr --new           # Force full workflow (create new worktree even on feature branch)
/task-to-pr --resume        # Resume from current context (default)
/task-to-pr --ci-only       # Skip to Phase 6 (CI monitoring)
/task-to-pr --stop-at-impl  # Stop after Phase 5 (implementation), no PR creation
```

## Inputs

Collect the following inputs (when available):

- `request`: User request or Issue URL
- `repo`: Repository path (default: `.`)
- `base`: Base branch name (default: repository default branch)
- `worktree`: Worktree name/path (optional)
- `pr_title`: PR title (optional; can be inferred from the request)
- `pr_labels`: PR labels (optional, when allowed by the repository)
- `--new`, `--resume`, `--ci-only`, `--stop-at-impl`: Execution mode overrides

## Workflow Overview

```
Phase 0: Context Detection (NEW)
  └─ Step 0: Detect current state and determine start phase

Phase 1: Planning
  ├─ Step 1: Context gathering and request validation
  └─ Step 2: Task decomposition and planning

Phase 2: Preparation (CONDITIONAL: skip if on feature branch)
  ├─ Step 3: Worktree creation
  └─ Step 4: Worktree initialization

Phase 3: Implementation
  └─ Step 5: Subtask implementation loop

Phase 4: Validation
  └─ Step 6: Run local checks

Phase 5: PR (CONDITIONAL: skip if PR exists or --stop-at-impl)
  ├─ Step 7: Prepare PR content
  └─ Step 8: Create PR

Phase 6: CI Monitoring (CONDITIONAL: skip if PR doesn't exist)
  ├─ Step 9: CI monitoring loop
  └─ Step 10: CI failure fix loop
```

## Detailed Workflow

### Phase 0: Context Detection (NEW)

#### Step 0: Detect Current State and Determine Start Phase

**Detect current context**:

```bash
current_branch=$(git branch --show-current)
default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
is_feature_branch=$([[ "$current_branch" != "$default_branch" ]] && echo "yes" || echo "no")
# gh pr view without arguments automatically checks the current branch's PR
pr_exists=$(gh pr view --json number 2>/dev/null && echo "yes" || echo "no")
```

**Determine execution path**:

```markdown
if user_override == "--new":
start_phase = Phase 1 (force full workflow)
elif user_override == "--ci-only":
start_phase = Phase 6 (CI monitoring only)
elif user_override == "--stop-at-impl":
start_phase = Phase 1 (but stop after Phase 5)
elif pr_exists == "yes":
start_phase = Phase 6 (PR exists, monitor/fix CI)
elif is_feature_branch == "yes":
start_phase = Phase 1 (skip Phase 2-3: worktree creation)
else:
start_phase = Phase 1 (full workflow)
```

**Communicate detected context to user**:

```
[Context Detection]
✓ Branch: {current_branch}
✓ Context: {New task|Resume implementation|CI fix}
→ Execution plan: Starting from Phase {N}
→ Skipping: {phases to skip}
```

### Phase 1: Planning

#### Step 1: Context Gathering and Request Validation

- If the input is an Issue URL, perform network access according to the environment policy.
  - Request permission before using `gh` or `curl` if needed.
  - If permission is not granted, ask the user to paste the Issue body/comments.
- Restate requirements and define acceptance criteria.
- Decide whether the request is valid. If inaccurate or ambiguous, explain the reason and confirm how to proceed.

#### Step 2: Task Decomposition and Planning

**Complexity assessment**:

- Simple: single file, clear change, 3 steps or fewer
- Complex: multiple files, architectural changes, more than 3 steps

**When Complex**:

- Register subtasks with `TaskCreate` (see `references/task-decomposition.md`)
- Set dependencies (`TaskUpdate` with `addBlockedBy`)
- For large/risky changes, share a plan and wait for approval

**When Simple**:

- No TaskCreate needed; proceed directly to next phase

### Phase 2: Preparation (CONDITIONAL)

**Skip if**:

- Current branch is a feature branch (not main/master)
- User specified `--ci-only`

**Execute if**:

- Current branch is main/master/default branch
- User specified `--new` (force)

#### Step 3: Worktree Creation

- Check if `git wt` is available (`command -v git-wt` or `git wt --help`).
  - If available: use `git wt` (see `references/git-wt.md`).
  - If not: fall back to `git worktree`.
- Choose a branch name (recommended: `feat/<short-slug>` in kebab-case).
- Create the worktree:
  - `git worktree add -b <branch> <path> <base>`
- `cd` into the worktree and verify with `git status`.

#### Step 4: Worktree Initialization

**Dependency installation (Node projects)**:

- If `package.json` exists, detect the package manager and install dependencies.
- Priority order:
  1. `package.json` `packageManager` field
  2. Lockfile in repo root:
     - `pnpm-lock.yaml` → `pnpm install`
     - `yarn.lock` → `yarn install`
     - `package-lock.json` / `npm-shrinkwrap.json` → `npm install`
  3. If `package.json` exists without a lockfile → use `ni` (if available) or ask the user

**Environment files (.env / .env.keys)**:

- If `.env` exists in the parent repo but not in the worktree → copy to worktree root
- If `.env.keys` exists in the parent repo → copy to worktree root (even if `.env` is committed)
- Do not commit secrets

### Phase 3: Implementation

#### Step 5: Subtask Implementation Loop

**When Complex**:

1. Use `TaskList` to get the next available task (prioritize by ID; `blockedBy` empty)
2. `TaskUpdate` status to `in_progress`
3. Implement the task (follow `AGENTS.md` and project rules)
4. `TaskUpdate` status to `completed`
5. Repeat until all subtasks are done

**When Simple**:

- Keep changes minimal and within scope
- Follow `AGENTS.md` and project rules

### Phase 4: Validation

#### Step 6: Run Local Checks

- Run the repository standard checks:
  - `lint`
  - `type-check`
  - `test`
  - `build` (or the closest equivalent)
- Report results and failures clearly

**If checks fail**:

- **Attempt to fix automatically** (see `references/ci-fix-patterns.md`)
- **Apply fixes locally but do NOT commit** - let the user review changes first
- If unable to fix, report to user and wait for resolution
- Do NOT proceed to Phase 5 (PR creation) if checks fail

### Phase 5: PR (CONDITIONAL)

**Skip if**:

- PR already exists for current branch
- Local checks failed (Phase 4)
- User specified `--stop-at-impl`

**Execute if**:

- No PR exists
- Local checks passed
- Not in `--ci-only` mode

#### Step 7: Prepare PR Content

- Search for PR templates in this order:
  1. `.github/PULL_REQUEST_TEMPLATE.md`
  2. `.github/PULL_REQUEST_TEMPLATE/*.md` (if multiple, confirm which to use)
  3. `PULL_REQUEST_TEMPLATE.md`
- Fill sections with:
  - Validation outcome (request correctness)
  - Changes made
  - Tests run and results
  - Risks or follow-ups

#### Step 8: Create PR

- Check `gh` authentication; if not authenticated, ask the user to log in
- Perform network actions per environment policy (request permission only if needed)
- Use `gh pr create` with the prepared template body
- Share the PR URL

### Phase 6: CI Monitoring (CONDITIONAL)

**Skip if**:

- No PR exists
- User specified `--stop-at-impl`

**Execute if**:

- PR exists (either created in Phase 5 or pre-existing)

#### Step 9: CI Monitoring Loop

**Automated monitoring process**:

```bash
while true; do
  gh pr checks
  # pending → wait (30-second interval)
  # success → done, skip Step 10
  # failure → go to Step 10

done
```

**User notifications**:

- On CI start: "CI is running. I'll monitor until completion."
- On success: "All CI checks succeeded ✓"
- On failure detection: "CI failure detected. I'll try automatic fixes." (no confirmation)

#### Step 10: CI Failure Fix Loop (Automatic, No Confirmation)

**Auto-fix process (max 3 attempts)**:

1. Get error details with `scripts/inspect_pr_checks.py`
2. Determine error category (type errors, lint, test failures, build errors)
3. Apply fix strategy (see `references/ci-fix-patterns.md`)
4. Implement fix → commit → push
5. Return to Step 9 and re-monitor

**When attempts are exceeded**:

- If CI still fails after 3 auto-fix attempts, report:
  - Fixes attempted
  - Remaining error details
  - Recommended next steps
- Ask for manual intervention

**Notes**:

- Fixes are executed automatically without confirmation
- Commit message format: `fix(ci): {error category} - {short description}`
- Always push after each fix to retrigger CI

## Progress Reporting (NEW)

**At the start of each phase, output**:

```
🔄 Phase N: <Phase Name>
├─ Current step: <Step description>
├─ Skipped: <phases skipped and why>
└─ Status: <in_progress|completed>
```

**Example**:

```
🔄 Phase 0: Context Detection
├─ Current step: Detecting work context
└─ Status: completed

[Context Detection]
✓ Branch: feat/user-auth (feature branch)
✓ Worktree: Yes
✓ PR: No
→ Detected context: Resume implementation
→ Starting from: Phase 1 (context gathering)
→ Skipping: Phase 2-3 (worktree creation - already in worktree)

🔄 Phase 1: Planning
├─ Current step: Context gathering and request validation
└─ Status: in_progress
```

## Decision Log (NEW)

**For debugging, output decision rationale**:

```
[Decision] Context: Resume implementation
  Reason: Current branch 'feat/user-auth' is not the default branch
  Action: Skipping Phase 2-3 (worktree creation)

[Decision] Complexity: Complex
  Reason: 3+ files affected (auth.ts, middleware.ts, tests/auth.test.ts)
  Action: Creating 4 subtasks with TaskCreate

[Decision] Plan approval: Skipped
  Reason: User did not specify --require-approval
  Action: Proceeding to Phase 3 (Implementation)
```

## Quick Reference

### Context Detection Commands

```bash
# Detect current branch
git branch --show-current

# Detect default branch
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'

# Check if PR exists
gh pr view --json number 2>/dev/null

# Check worktree status
git worktree list
```

### Execution Mode Examples

```bash
# Standard: auto-detect context
/task-to-pr Add user authentication

# Force new worktree creation
/task-to-pr --new Add user authentication

# CI monitoring only (PR already exists)
/task-to-pr --ci-only

# Stop before PR creation
/task-to-pr --stop-at-impl Refactor auth module
```

### Task Decomposition Decision

```bash
# Criteria for Complex
- 3+ steps
- multiple file changes
- architecture changes
→ register subtasks with TaskCreate

# Criteria for Simple
- single file
- clear change
- 3 steps or fewer
→ no TaskCreate needed
```

### CI Monitoring Commands

```bash
# Check CI status
gh pr checks

# Fetch error details
python scripts/inspect_pr_checks.py

# Push after auto-fix
git add . && git commit -m "fix(ci): {category} - {short description}" && git push
```

## Output Expectations

- Respond in Japanese
- Always output context detection results (Phase 0)
- Always output decision rationale for phase skipping
- If the request cannot be validated, explain why and confirm next steps
- If multiple PR templates exist, confirm which to use
- **Commit policy**:
  - Phase 1-5: Do not commit unless explicitly requested by the user
  - Phase 6 (CI fixes): Automatically commit and push fixes without confirmation (up to 3 attempts)
- CI monitoring and fixes run automatically (no confirmation; report only when attempts are exceeded)

## Terminology and Style Guide

- Tool names must be exact and wrapped in backticks: `TaskCreate`, `TaskList`, `TaskUpdate`.
- Field names must be exact and wrapped in backticks: `blockedBy`, `activeForm`, `in_progress`, `completed`, `deleted`.
- Use "subtask" (one word), "worktree" (lowercase), "PR" (uppercase), "CI" (uppercase), and "GitHub" (proper case).
- Use backticks for commands, file paths, and placeholders like `{category}` or `{short description}`.
- Use conventional commits for CI fixes: `fix(ci): {error category} - {short description}`.
- Keep examples and templates in English for consistency.

## Bundled Resources

- `references/task-decomposition.md` - Task decomposition guide
- `references/ci-fix-patterns.md` - CI fix patterns
- `references/git-wt.md` - git wt quick reference
- `scripts/inspect_pr_checks.py` - CI failure detection script
