# Git Worktree Workflow Patterns

Practical workflow patterns for Git worktree usage in various development scenarios.

## Core Workflows

### Feature Branch Development

Standard workflow for feature development with worktrees.

### Setup

```bash
# Main repository stays on default branch (main)
cd /path/to/repo
git status  # Should be clean

# Create worktree for new feature
git wt create feature/user-authentication
cd .worktrees/user-authentication
```

### Development

```bash
# Work on feature
vim src/auth.ts
git add src/auth.ts
git commit -m "feat: add user authentication"

# Continue development
vim tests/auth.test.ts
git add tests/auth.test.ts
git commit -m "test: add authentication tests"
```

### Cleanup

```bash
# After PR is merged
cd /path/to/repo
git wt remove feature/user-authentication
git branch -d feature/user-authentication
```

### Parallel Feature Development

Working on multiple features simultaneously.

### Scenario

```bash
# Feature A: Primary work
git wt create feature/api-endpoints
cd .worktrees/api-endpoints
# ... work on Feature A ...

# Feature B: Secondary work (while Feature A's tests run)
cd /path/to/repo
git wt create feature/ui-components
cd .worktrees/ui-components
# ... work on Feature B ...

# Switch between features easily
cd /path/to/repo
git wt switch feature/api-endpoints
# or
gwts  # Interactive selection (with Zsh integration)
```

### Benefits

- No stashing required
- Each feature has its own `node_modules` (if needed)
- Independent test/build processes

### Hotfix Workflow

Quickly fix production issues without affecting current work.

### Scenario

```bash
# Current work (in progress, uncommitted changes)
cd .worktrees/feature-in-progress
git status  # Shows uncommitted changes

# Create hotfix worktree from production branch
cd /path/to/repo
git wt create hotfix/critical-bug --start-point origin/production

# Work on hotfix
cd .worktrees/critical-bug
vim src/buggy-code.ts
git add .
git commit -m "fix: resolve critical production bug"
git push origin hotfix/critical-bug

# Create PR, get it merged

# Clean up
cd /path/to/repo
git wt remove hotfix/critical-bug

# Resume original work (no stash/unstash needed)
cd .worktrees/feature-in-progress
# Continue working...
```

### PR Review Workflow

Review and test PRs without affecting your current work.

```bash
# Fetch PR branch
git fetch origin pull/123/head:pr-123

# Create worktree for PR review
git wt create -b pr-123

# Test PR
cd .worktrees/pr-123
npm install
npm test
npm run build

# Leave review comments, then clean up
cd /path/to/repo
git wt remove pr-123
git branch -d pr-123
```

### Tip

```bash
# Fetch and create worktree in one command
gh pr checkout 123 && git wt create -b pr-123
```

## Advanced Workflows

### AI Agent Parallel Execution

Multiple AI agents working on different tasks in parallel.

### Architecture

```
Main Repo (coordinator)
├── .worktrees/agent-1-task-a/  # Agent 1: Feature A
├── .worktrees/agent-2-task-b/  # Agent 2: Feature B
└── .worktrees/agent-3-task-c/  # Agent 3: Feature C
```

### Setup Script

```bash
#!/bin/bash
# setup-agent-worktrees.sh

TASKS=("task-a" "task-b" "task-c")

for i in "${!TASKS[@]}"; do
  TASK="${TASKS[$i]}"
  AGENT_ID=$((i + 1))

  # Create worktree for each agent
  git wt create "agent-${AGENT_ID}-${TASK}"

  # Copy necessary files
  cp .env ".worktrees/${TASK}/.env"

  echo "Worktree for Agent ${AGENT_ID} (${TASK}) created"
done
```

### Agent Execution

```bash
# Agent 1
cd .worktrees/agent-1-task-a
# ... AI agent works here ...

# Agent 2 (parallel)
cd .worktrees/agent-2-task-b
# ... AI agent works here ...

# Agent 3 (parallel)
cd .worktrees/agent-3-task-c
# ... AI agent works here ...
```

### Cleanup

```bash
#!/bin/bash
# cleanup-agent-worktrees.sh

TASKS=("task-a" "task-b" "task-c")

for i in "${!TASKS[@]}"; do
  TASK="${TASKS[$i]}"
  AGENT_ID=$((i + 1))

  # Remove worktree
  git wt remove "agent-${AGENT_ID}-${TASK}"

  # Delete branch (if merged)
  git branch -d "agent-${AGENT_ID}-${TASK}"
done
```

### Continuous Integration (CI) Workflow

Use worktrees for parallel CI builds.

### Scenario

```bash
#!/bin/bash
# ci-parallel-test.sh

BRANCHES=("main" "develop" "feature/new-api")

for branch in "${BRANCHES[@]}"; do
  # Create worktree for each branch
  git wt create -b "$branch" --path "ci-builds/${branch//\//-}"

  # Run tests in background
  (
    cd "ci-builds/${branch//\//-}"
    npm install
    npm test
    npm run build
  ) &
done

# Wait for all tests to complete
wait

echo "All CI tests completed"
```

### Benefits

- Parallel execution (faster CI)
- Isolated dependencies
- No branch switching overhead

### Release Branch Maintenance

Maintain multiple release branches simultaneously.

### Scenario

```bash
# Create worktrees for each release branch
git wt create -b release/v1.x --path releases/v1
git wt create -b release/v2.x --path releases/v2
git wt create -b release/v3.x --path releases/v3

# Backport fix to all versions
cd releases/v1
git cherry-pick abc123
git push origin release/v1.x

cd ../v2
git cherry-pick abc123
git push origin release/v2.x

cd ../v3
git cherry-pick abc123
git push origin release/v3.x
```

### Bisect with Worktrees

Use worktrees for git bisect without interrupting current work.

```bash
# Create worktree for bisect
git wt create bisect-session --detach

cd .worktrees/bisect-session

# Start bisect
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# Test each commit
while [ $? -ne 0 ]; do
  npm test
  if [ $? -eq 0 ]; then
    git bisect good
  else
    git bisect bad
  fi
done

# Found bad commit
git bisect log

# Clean up
cd /path/to/repo
git wt remove bisect-session
```

## Hooks

### Post-Add Hook: Dependency Installation

Automatically install dependencies when creating worktree.

```bash
#!/bin/bash
# .git/hooks/post-worktree-add

WORKTREE_PATH=$1
BRANCH=$2

echo "Installing dependencies in $WORKTREE_PATH..."

cd "$WORKTREE_PATH"

# Node.js project
if [ -f "package.json" ]; then
  npm install
fi

# Python project
if [ -f "requirements.txt" ]; then
  pip install -r requirements.txt
fi

# Ruby project
if [ -f "Gemfile" ]; then
  bundle install
fi

echo "Dependencies installed for $BRANCH"
```

### Post-Add Hook: Environment Setup

Copy configuration files and set up environment.

```bash
#!/bin/bash
# .git/hooks/post-worktree-add

WORKTREE_PATH=$1
BRANCH=$2
MAIN_REPO=$(git rev-parse --show-toplevel)

echo "Setting up environment in $WORKTREE_PATH..."

cd "$WORKTREE_PATH"

# Copy environment files
if [ -f "$MAIN_REPO/.env.example" ]; then
  cp "$MAIN_REPO/.env.example" .env
  echo ".env file created from .env.example"
fi

# Copy local configuration
if [ -f "$MAIN_REPO/config.local.json" ]; then
  cp "$MAIN_REPO/config.local.json" config.local.json
  echo "config.local.json copied"
fi

# Copy IDE settings
if [ -d "$MAIN_REPO/.vscode" ]; then
  cp -r "$MAIN_REPO/.vscode" .vscode
  echo ".vscode settings copied"
fi

echo "Environment setup completed for $BRANCH"
```

### Post-Remove Hook: Cleanup

Clean up build artifacts and caches.

```bash
#!/bin/bash
# .git/hooks/post-worktree-remove

WORKTREE_PATH=$1
BRANCH=$2

echo "Cleaning up $WORKTREE_PATH..."

# Remove build artifacts
rm -rf "$WORKTREE_PATH/dist"
rm -rf "$WORKTREE_PATH/build"
rm -rf "$WORKTREE_PATH/.next"

# Remove caches
rm -rf "$WORKTREE_PATH/node_modules/.cache"
rm -rf "$WORKTREE_PATH/.cache"

# Remove temporary files
rm -rf "$WORKTREE_PATH/tmp"
rm -rf "$WORKTREE_PATH/*.log"

echo "Cleanup completed for $BRANCH"
```

## Team Collaboration

### Shared Worktree Convention

Establish team conventions for worktree usage.

### Team Guidelines

1. Base Directory: Always use `.worktrees/`
2. Naming Convention: `{type}/{description}` (e.g., `feature/user-auth`)
3. Main Branch Protection: Never work directly in main repository
4. Cleanup: Remove worktrees after PR merge

### Shared Configuration

```gitattributes
# .gitattributes
.worktrees/** linguist-vendored
```

### Shared Configuration

```gitignore
# .gitignore
.worktrees/
```

### Shared Configuration

```toml
# mise.toml
[tasks.worktree-create]
run = "git wt create $1"

[tasks.worktree-cleanup]
run = "git wt list | grep -v main | xargs -I {} git wt remove {}"
```

### Code Review with Worktrees

Efficient code review workflow for teams.

### Reviewer Workflow

```bash
# Reviewer fetches PR
gh pr checkout 456

# Create worktree for review
git wt create -b pr-456-review

cd .worktrees/pr-456-review

# Run tests
npm test

# Test manually
npm run dev

# Leave review
gh pr review 456 --comment -b "LGTM! Tests pass."

# Clean up
cd /path/to/repo
git wt remove pr-456-review
```

### Author Workflow

```bash
# Create worktree for PR fixes
git wt create -b pr-456-fixes

cd .worktrees/pr-456-fixes

# Address comments
vim src/file.ts
git add .
git commit -m "fix: address review comments"
git push origin pr-456-fixes

# Clean up after merge
cd /path/to/repo
git wt remove pr-456-fixes
```

## Performance Optimization

### Shared Object Database

Worktrees share the same `.git` object database, saving disk space.

### Disk Usage Comparison

```bash
# Without worktrees (3 clones)
3 × (repo size) = 3 × 1GB = 3GB

# With worktrees (1 repo + 2 worktrees)
1 × (repo size) + 2 × (working directory) = 1GB + 2 × 100MB = 1.2GB
```

### Savings

### Parallel Operations

Leverage worktrees for parallel operations.

### Example: Parallel Testing

```bash
#!/bin/bash
# parallel-test.sh

BRANCHES=("main" "develop" "feature/new-feature")

for branch in "${BRANCHES[@]}"; do
  (
    git wt create -b "$branch" --path "test-${branch//\//-}"
    cd "test-${branch//\//-}"
    npm test
    cd ..
    git wt remove "test-${branch//\//-}"
  ) &
done

wait
echo "All tests completed"
```

### Build Caching

Share build caches between worktrees.

### Configuration

```bash
# Shared cache directory
BUILD_CACHE_DIR=/path/to/repo/.cache/build
NODE_MODULES_CACHE=/path/to/repo/.cache/node_modules
```

### Hook Integration

```bash
#!/bin/bash
# .git/hooks/post-worktree-add

CACHE_DIR="/path/to/repo/.cache"
WORKTREE_PATH=$1

# Link shared cache
ln -s "$CACHE_DIR" "$WORKTREE_PATH/.cache"

echo "Shared cache linked"
```

## Troubleshooting Workflows

### Stale Worktree Recovery

Recover from accidentally deleted worktree directories.

```bash
# List all worktrees (including stale)
git worktree list

# Prune stale worktrees
git worktree prune -v

# Recreate if needed
git wt create -b existing-branch
```

### Locked Worktree Resolution

Resolve locked worktree issues.

```bash
# Check if worktree is locked
git worktree list

# Unlock worktree
git worktree unlock .worktrees/locked-worktree

# Remove worktree
git wt remove locked-worktree
```

## See Also

- [Command Reference](git-wt-commands.md)
- [Configuration Options](configuration.md)
- [Troubleshooting](troubleshooting.md)

---

### Version

### Last Updated
