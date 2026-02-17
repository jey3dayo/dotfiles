# git-wt Command Reference

Complete reference for all `git-wt` commands and options.

## Overview

`git-wt` is a wrapper around `git worktree` that provides additional features like hooks, file copying, and shell integration. This reference covers version 0.15.0+.

## Global Options

Available for all commands:

```bash
--help, -h        # Show help
--version, -v     # Show version
--config, -c      # Specify config file
```

## Commands

### list

List all worktrees.

```bash
git wt list [options]
```

### Options

- `--verbose`: Show detailed information (branch, commit, status)
- `--porcelain`: Machine-readable output

### Examples

```bash
# Simple list
git wt list

# Detailed information
git wt list --verbose

# Machine-readable format
git wt list --porcelain
```

### Output Format

```
feature-a    .worktrees/feature-a    [feature/a 1a2b3c4] WIP: implement auth
feature-b    .worktrees/feature-b    [feature/b 5d6e7f8] fix: resolve conflicts
```

### create

Create a new worktree.

```bash
git wt create <branch> [options]
```

### Arguments

- `<branch>`: Branch name for the new worktree

### Options

- `--path <path>`: Custom worktree path (default: auto-generated from branch name)
- `--start-point <ref>`: Start point (commit, tag, branch)
- `-b, --branch`: Use existing branch instead of creating new one
- `--copy <file>`: Copy file(s) to new worktree (can be repeated)
- `--force, -f`: Force creation even if branch exists
- `--detach`: Create detached HEAD
- `--checkout`: Checkout after creation (default: true)
- `--no-checkout`: Don't checkout after creation

### Examples

```bash
# Create new branch and worktree
git wt create feature/user-auth

# Custom path
git wt create feature/api --path .worktrees/api-feature

# From existing branch
git wt create -b origin/feature/existing

# From specific commit
git wt create feature/hotfix --start-point v1.2.3

# Copy files to new worktree
git wt create feature/test --copy .env --copy config.json

# Detached HEAD (for testing commits)
git wt create --detach abc123def
```

### Auto-generated Path

Branch name `feature/user-auth` → Worktree path `.worktrees/user-auth`

Customizable via `wt.nameTemplate` config.

### switch

Switch to a worktree (requires shell integration).

```bash
git wt switch [worktree]
```

### Arguments

- `[worktree]`: Worktree name or path (optional for interactive mode)

### Options

- `--interactive, -i`: Interactive selection (fuzzy finder)

### Examples

```bash
# Switch by branch name
git wt switch feature/user-auth

# Switch by path
git wt switch .worktrees/user-auth

# Interactive selection
git wt switch
git wt switch -i
```

### Note

### remove

Remove a worktree.

```bash
git wt remove <worktree> [options]
```

### Arguments

- `<worktree>`: Worktree name or path

### Options

- `--force, -f`: Force removal (ignore uncommitted changes)

### Examples

```bash
# Safe removal (checks for uncommitted changes)
git wt remove feature/user-auth

# Force removal
git wt remove -f feature/old-experiment

# By path
git wt remove .worktrees/temporary
```

### Safety Check

Without `--force`, `git wt remove` will fail if:

- Uncommitted changes exist
- Untracked files exist (configurable)

### prune

Clean up worktree information.

```bash
git wt prune [options]
```

### Options

- `--dry-run, -n`: Show what would be pruned
- `--verbose, -v`: Show detailed information

### Examples

```bash
# Prune stale worktree information
git wt prune

# Dry run
git wt prune --dry-run

# Verbose output
git wt prune -v
```

### Use Cases

- Worktree directory deleted manually
- Corrupted worktree metadata
- After moving worktree directories

### lock / unlock

Lock/unlock a worktree to prevent removal.

```bash
git wt lock <worktree> [options]
git wt unlock <worktree>
```

### Arguments

- `<worktree>`: Worktree name or path

### Options

- `--reason <reason>`: Reason for locking

### Examples

```bash
# Lock worktree
git wt lock feature/important --reason "Long-running build"

# Unlock worktree
git wt unlock feature/important
```

### Use Cases

- Prevent accidental removal during long-running operations
- Mark worktrees as critical

### move

Move a worktree to a new location.

```bash
git wt move <worktree> <new-path>
```

### Arguments

- `<worktree>`: Current worktree name or path
- `<new-path>`: New path for worktree

### Examples

```bash
# Move worktree
git wt move feature/test .worktrees/test-new-location

# Reorganize worktrees
git wt move old-path/.worktrees/feature .worktrees/feature
```

### Note

### repair

Repair worktree metadata.

```bash
git wt repair [worktree]
```

### Arguments

- `[worktree]`: Specific worktree to repair (optional, repairs all if omitted)

### Examples

```bash
# Repair all worktrees
git wt repair

# Repair specific worktree
git wt repair feature/broken
```

### Use Cases

- Corrupted worktree metadata
- After manual directory moves
- After repository migration

## Hook System

### Post-Add Hook

Executed after worktree creation.

### Location

### Arguments

1. Worktree path
2. Branch name

### Example

```bash
#!/bin/bash
# .git/hooks/post-worktree-add

WORKTREE_PATH=$1
BRANCH=$2

# Install dependencies
cd "$WORKTREE_PATH"
npm install

# Copy config files
cp ../config.local.json ./config.local.json

echo "Worktree $BRANCH initialized at $WORKTREE_PATH"
```

### Post-Remove Hook

Executed after worktree removal.

### Location

### Arguments

1. Worktree path
2. Branch name

### Example

```bash
#!/bin/bash
# .git/hooks/post-worktree-remove

WORKTREE_PATH=$1
BRANCH=$2

# Clean up build artifacts
rm -rf "$WORKTREE_PATH/dist"

echo "Worktree $BRANCH removed from $WORKTREE_PATH"
```

## Exit Codes

| Code | Meaning                               |
| ---- | ------------------------------------- |
| 0    | Success                               |
| 1    | General error                         |
| 2    | Misuse (invalid arguments)            |
| 3    | Worktree already exists               |
| 4    | Worktree not found                    |
| 5    | Uncommitted changes (without --force) |
| 128  | Git internal error                    |

## Environment Variables

| Variable          | Description                       | Default                        |
| ----------------- | --------------------------------- | ------------------------------ |
| `GIT_WT_CONFIG`   | Config file path                  | `~/.config/git-wt/config.yaml` |
| `GIT_WT_BASE_DIR` | Base directory for worktrees      | From config or `.worktrees`    |
| `GIT_WT_EDITOR`   | Editor for interactive operations | `$EDITOR` or `vim`             |

## Comparison with git worktree

| Feature              | git wt | git worktree |
| -------------------- | ------ | ------------ |
| Basic operations     | ✅     | ✅           |
| Hooks                | ✅     | ❌           |
| File copying         | ✅     | ❌           |
| Shell integration    | ✅     | ❌           |
| Interactive mode     | ✅     | ❌           |
| Auto-generated paths | ✅     | ❌           |
| Config file          | ✅     | ❌           |
| Script-friendly      | ✅     | ✅           |

### Recommendation

- **Development**: Use `git wt` for enhanced features
- **Automation/CI**: Use `git worktree` for portability

## See Also

- [Configuration Options](configuration.md)
- [Workflow Patterns](workflows.md)
- [Troubleshooting](troubleshooting.md)

---

### Version

### Last Updated
