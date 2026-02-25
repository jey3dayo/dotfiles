---
name: sync-origin
description: |
  Sync the current branch with the remote default branch (main/master/develop, etc.)
  and automatically resolve conflicts. Triggered by: "mainと同期して"、"最新にして"、"originと同期"、
  "sync with origin", "pull main", "rebase on main", "update from main", etc.
metadata:
  short-description: Sync current branch with remote default branch
---

# Sync Origin

## Overview

A skill that syncs the current branch with the remote default branch and attempts to automatically resolve any conflicts. Supports auto-detection of the default branch, merge/rebase selection, and incremental conflict resolution.

## Trigger Conditions

Activated by requests such as:

### Japanese

- "mainと同期して"
- "最新にして"
- "originと同期"
- "デフォルトブランチから更新"
- "main/master/developからpull"

### English

- "sync with origin"
- "pull main"
- "rebase on main"
- "update from main"
- "sync current branch with default"

## Workflow

### 1. Pre-flight Check

Before starting work, verify the following:

```bash
# Check current branch
git branch --show-current

# Check working tree status
git status --short

# Warn if there are uncommitted changes
```

### When There Are Uncommitted Changes

- Ask user for confirmation
- Present options: stash, commit, or abort the operation

### 2. Default Branch Detection

Automatically detect the remote default branch:

```bash
# Use the bundled script
bash ~/.agents/skills/sync-origin/scripts/detect-default-branch.sh [remote-name]
```

### Detection Methods (in priority order)

1. `git symbolic-ref refs/remotes/origin/HEAD`
2. `git remote show origin | grep "HEAD branch"`
3. Check common branch names (main, master, develop)

### Explicit Specification

If the user specifies `--base <branch>`, that value takes priority.

### 3. Fetch from Remote

Retrieve the latest information:

```bash
git fetch origin
```

### 4. Sync Process

#### 4.1 Merge (Default)

```bash
git merge origin/<default-branch>
```

#### 4.2 Rebase (when `--rebase` option is used)

```bash
git rebase origin/<default-branch>
```

### 5. Conflict Resolution

If conflicts occur, attempt the following incremental resolution:

#### 5.1 Auto-Resolvable Cases

The following cases are resolved automatically:

- Cases where ours/theirs strategy is clear:
  - Documentation files (README.md, etc.): prefer ours
  - Generated config files (package-lock.json, etc.): regenerate
  - Auto-generated files: prefer theirs

```bash
# Example: conflict in package-lock.json
git checkout --theirs package-lock.json
npm install  # regenerate
git add package-lock.json
```

#### 5.2 Cases Requiring Manual Resolution

When auto-resolution is not possible (e.g., conflicts in source code):

1. Present list of conflicted files
2. Review the content of each file
3. Consult user on how to resolve

```bash
# List of conflicted files
git diff --name-only --diff-filter=U

# Details for each file
git diff <file>
```

### Options Presented to User

- Review each file's content and merge manually
- `git checkout --ours <file>` to keep current changes
- `git checkout --theirs <file>` to adopt remote changes
- Abort the merge (`git merge --abort` or `git rebase --abort`)

### 6. Completion Check

Once sync is complete, verify the state:

```bash
# Check final state
git status

# Check log (recent changes)
git log --oneline -10

# Check diff with remote
git log HEAD..origin/<default-branch> --oneline
```

## Options

### `--base <branch>`

Explicitly specify the branch to sync with.

```bash
# Usage example
"developブランチと同期して" + --base develop
```

### `--rebase`

Use rebase instead of merge.

```bash
# Usage example
"mainをrebaseして" + --rebase
```

### `--dry-run`

Preview what would happen without actually making changes.

```bash
# Preview what would be executed
git fetch origin
git merge-base HEAD origin/<default-branch>
git log --oneline HEAD..origin/<default-branch>
```

### `--auto-stash`

Automatically stash uncommitted changes (only valid with rebase).

```bash
git rebase --autostash origin/<default-branch>
```

## Error Handling

### 1. Remote Does Not Exist

```bash
# Error: fatal: 'origin' does not appear to be a git repository
```

### Resolution

### 2. Default Branch Cannot Be Detected

```bash
# Error: Could not detect default branch
```

### Resolution

### 3. Network Error

```bash
# Error: fatal: unable to access '...': Could not resolve host
```

### Resolution

### 4. Conflict Cannot Be Resolved

### Resolution Steps

1. Save current state: `git stash`
2. Retry from a clean state
3. If still unresolvable, suggest manual merge

## Best Practices

1. Sync regularly: If a branch has not been updated for a long time, sync before conflicts become complex
2. Sync before committing: Sync with the latest state before committing your work
3. rebase vs merge:
   - To keep a clean history: `--rebase`
   - To preserve merge commits: default (merge)
4. Use dry-run: When significant changes are expected, first check with `--dry-run`

## Examples

### Example 1: Basic Sync

```
User: "mainと同期して"

1. Check current branch: feature/new-feature
2. Detect default branch: main
3. git fetch origin
4. git merge origin/main
5. No conflicts → Complete
```

### Example 2: Sync with Rebase

```
User: "mainをrebaseして"

1. Check current branch: feature/fix-bug
2. Detect default branch: main
3. git fetch origin
4. git rebase origin/main
5. Conflicts found → Attempt auto-resolution
6. package-lock.json: auto-resolved (regenerated)
7. src/app.ts: requires manual resolution → Consult user
```

### Example 3: Explicit Branch Specification

```
User: "developと同期して" + --base develop

1. Use specified branch: develop
2. git fetch origin
3. git merge origin/develop
4. Complete
```

## Resources

### scripts/detect-default-branch.sh

A Bash script for detecting the remote default branch.

### Usage

```bash
bash ~/.agents/skills/sync-origin/scripts/detect-default-branch.sh [remote-name]
```

### Output

- Success: Default branch name (e.g., main)
- Failure: Error message (stderr), exit code 1

### Detection Logic

1. Detection via `git symbolic-ref`
2. Detection via `git remote show`
3. Check common branch names (main, master, develop)
