---
name: git-worktree
description: |
  Git worktree management using git-wt (k1LoW) and native git worktree commands.
  Use when: (1) Managing multiple feature branches in parallel,
  (2) Need to switch between branches without stashing,
  (3) Setting up AI agent parallel workflows,
  (4) Working with .worktrees directory structure.
  Keywords: worktree, git-wt, parallel development, branch isolation, .worktrees
---

# Git Worktree Management

A comprehensive guide for parallel development using Git worktrees. Provides effective usage of `git-wt` (k1LoW version) and native `git worktree` commands.

## Quick Start

### Basic Commands

```bash
# List worktrees
git wt list

# Create new worktree (new branch)
git wt create feature/new-feature

# Create worktree with existing branch
git wt create -b existing-branch

# Switch to worktree
git wt switch feature/new-feature

# Remove worktree (safe)
git wt remove feature/new-feature

# Remove worktree (force)
git wt remove -f feature/new-feature
```

### git wt vs git worktree

- git wt: k1LoW's feature-rich wrapper (supports hooks, file copying, shell integration)
- git worktree: Git's native official command (simple, standard)

### Recommendation

## Core Concepts

### What is a Worktree?

Git worktree is a feature that allows you to work on different branches of the same repository in separate directories simultaneously.

### Benefits

- No need to stash when switching branches
- Easy parallel development (working on multiple PRs simultaneously)
- Parallel build/test execution
- Task parallelization by AI agents

### Limitations

- The same branch cannot be checked out in multiple worktrees simultaneously
- The main repository (location with `.git` directory) should be protected

### .worktrees Directory Structure

This repository uses `.worktrees/` as the standard directory:

```
/path/to/repo/
├── .git/
├── .worktrees/
│   ├── feature-a/       # Branch: feature/a
│   ├── feature-b/       # Branch: feature/b
│   └── hotfix-123/      # Branch: hotfix/123
├── main-branch-files...
└── ...
```

### Configuration

### Alternative

### Protecting the Default Branch

Best practice is to not use the main repository (`main`/`master`/`develop`) for work, and only work in worktrees:

```bash
# Keep the main repository clean
cd /path/to/repo
git status  # Should be clean

# Work in worktrees
cd .worktrees/feature-x
# ... work here ...
```

## Common Operations

### Creating New Worktrees

### Create with New Branch

```bash
# Basic form (auto-generate worktree name from branch name)
git wt create feature/user-auth
# -> .worktrees/user-auth/ is created

# Explicitly specify worktree name
git wt create feature/user-auth --path .worktrees/auth-feature

# Create from specific commit
git wt create feature/bugfix --start-point v1.2.3
```

### Create with Existing Branch

```bash
# From remote branch
git wt create -b origin/feature/existing

# From local branch
git wt create -b feature/local-branch
```

### Switching Worktrees

```bash
# Switch by branch name
git wt switch feature/user-auth

# Switch by worktree path
git wt switch .worktrees/user-auth

# Interactive selection (fuzzy finder)
git wt switch
```

### Note

### Removing Worktrees

### Safe Removal

```bash
git wt remove feature/user-auth
```

### Force Removal

```bash
git wt remove -f feature/user-auth
```

### Clean Up Untracked Worktrees

```bash
git worktree prune
```

### Listing and Checking Information

```bash
# Simple list
git wt list

# Detailed information (branch, commit, status)
git wt list --verbose

# Check with native command
git worktree list
```

## Configuration

### Main Configuration Items

```bash
# Base directory for worktrees (required)
git config wt.basedir ".worktrees"

# Default worktree name generation pattern
git config wt.nameTemplate "{{.BranchName}}"

# Automatically set upstream
git config wt.autoSetupRemote true
```

### Global Configuration

```bash
git config --global wt.basedir ".worktrees"
```

### Repository Local Configuration

```bash
git config --local wt.basedir ".worktrees"
```

Refer to [`references/configuration.md`](references/configuration.md) for detailed configuration options.

## Advanced Features

### Hooks

Hooks that are automatically executed when worktrees are created/removed:

- `.git/hooks/post-worktree-add`: After worktree creation
- `.git/hooks/post-worktree-remove`: After worktree removal

### Usage Examples

Refer to [`references/workflows.md`](references/workflows.md#hooks) for details.

### File Copy Options

Copy specific files when creating a worktree:

```bash
# Copy .env file
git wt create feature/test --copy .env

# Multiple files
git wt create feature/test --copy .env --copy config.local.json
```

Automatic copying can also be configured:

```bash
git config wt.copyFiles ".env,config.local.json"
```

### Shell Integration

### Zsh Integration

The following functions are implemented in `zsh/config/tools/git.zsh`:

- `gwt`: alias for git wt
- `gwtl`: git wt list
- `gwtc`: git wt create (interactive selection)
- `gwts`: git wt switch (interactive selection)
- `gwtr`: git wt remove (interactive selection)

### Usage

```bash
# Create worktree interactively
gwtc

# Switch to worktree interactively
gwts

# List display
gwtl
```

## Real-World Workflows

### AI Agent Parallel Execution

Multiple AI agents working in their respective worktrees:

```bash
# Agent 1: Feature A
git wt create feature/agent-task-a
cd .worktrees/agent-task-a
# ... agent works here ...

# Agent 2: Feature B (parallel execution)
git wt create feature/agent-task-b
cd .worktrees/agent-task-b
# ... agent works here ...
```

### Simultaneous PR Work

Working on multiple PRs simultaneously:

```bash
# Fix PR #123
git wt create -b pr-123-fixes

# Review PR #124 (parallel work)
git wt create -b pr-124-review

# Main development (further parallel)
git wt create feature/new-feature
```

### Parallel Build/Test Execution

```bash
# Running tests in main worktree
cd .worktrees/feature-a
npm test &

# Continue development in another worktree
cd .worktrees/feature-b
# ... continue working ...
```

Refer to [`references/workflows.md`](references/workflows.md) for detailed workflow patterns.

## Troubleshooting

### Common Issues

### Issue

```bash
# Cause: Same branch is being used in another worktree
# Solution: Use a different branch name or delete the existing worktree

git wt list  # Check branches in use
git wt remove feature/x  # Delete if necessary
```

### Issue

```bash
# Cause: Only Git metadata was deleted
# Solution: Manually delete directory + prune

rm -rf .worktrees/old-worktree
git worktree prune
```

### Issue

```bash
# Check with diagnostic script
scripts/check-worktree-config.sh

# Check configuration
git config wt.basedir
git config --list | grep wt.
```

Refer to [`references/troubleshooting.md`](references/troubleshooting.md) for detailed troubleshooting.

## References

- [Command Reference](references/git-wt-commands.md): Detailed reference for all commands
- [Configuration](references/configuration.md): Detailed all configuration options
- [Workflows](references/workflows.md): Practical workflow patterns
- [Troubleshooting](references/troubleshooting.md): Problem resolution guide

## External Resources

- [git-wt GitHub Repository](https://github.com/k1LoW/git-wt)
- [Git Official Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Worktrunk - AI Agent Parallel Workflows](https://github.com/max-sixty/worktrunk)

## Integration Notes

### Zsh Functions

The following are implemented in `zsh/config/tools/git.zsh` of this repository:

- Worktree management functions (`gwt*` aliases)
- Interactive selection (fzf integration)
- Auto-completion

### Git Config

Default configuration (`git/config`):

```ini
[wt]
    basedir = .worktrees
```

### Ignore Files

`.worktrees/` is configured to be excluded in the following files:

- `.gitignore`
- `.fdignore`
- `.prettierignore`
- `mise/config.toml` (task exclusion)

---

### Version

### Last Updated

### Target
