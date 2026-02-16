# Git Worktree Troubleshooting

Comprehensive troubleshooting guide for common Git worktree issues and their solutions.

## Common Issues

### Issue: Branch Already Checked Out

**Symptom**:

```
fatal: 'feature/user-auth' is already checked out at '/path/to/repo/.worktrees/user-auth'
```

**Cause**: The same branch is already used in another worktree. Git prevents checking out the same branch in multiple worktrees.

**Solutions**:

#### Option 1: Switch to existing worktree

```bash
# List worktrees to find the existing one
git wt list

# Switch to existing worktree
git wt switch feature/user-auth
# or
cd .worktrees/user-auth
```

#### Option 2: Remove existing worktree

```bash
# Remove the existing worktree
git wt remove feature/user-auth

# Create new worktree
git wt create feature/user-auth
```

#### Option 3: Use different branch name

```bash
# Create with a different branch name
git wt create feature/user-auth-v2
```

**Prevention**: Always check existing worktrees before creating new ones.

### Issue: Worktree Directory Deleted Manually

**Symptom**:

```
# git wt list shows worktree, but directory doesn't exist
fatal: '/path/to/repo/.worktrees/deleted' does not exist
```

**Cause**: Worktree directory was deleted manually without using `git wt remove`.

**Solution**:

```bash
# Prune stale worktree metadata
git worktree prune -v

# Verify cleanup
git wt list
```

**If prune doesn't work**:

```bash
# Manual cleanup
rm -rf .git/worktrees/deleted

# Verify
git wt list
```

**Prevention**: Always use `git wt remove` to delete worktrees.

### Issue: Locked Worktree Cannot Be Removed

**Symptom**:

```
fatal: 'feature/locked' is locked; reason: Long-running build
```

**Cause**: Worktree was locked to prevent accidental removal.

**Solution**:

```bash
# Unlock worktree
git worktree unlock .worktrees/locked

# Remove worktree
git wt remove feature/locked
```

**Force removal** (if unlock fails):

```bash
# Remove lock file manually
rm .git/worktrees/locked/locked

# Remove worktree
git wt remove feature/locked
```

**Prevention**: Document lock reasons and unlock when no longer needed.

### Issue: Uncommitted Changes Prevent Removal

**Symptom**:

```
error: Worktree contains uncommitted changes
fatal: Cannot remove worktree 'feature/work-in-progress'
```

**Cause**: Worktree has uncommitted changes and `--force` flag not used.

**Solutions**:

#### Option 1: Commit changes

```bash
cd .worktrees/work-in-progress
git add .
git commit -m "save work in progress"
cd /path/to/repo
git wt remove work-in-progress
```

#### Option 2: Stash changes

```bash
cd .worktrees/work-in-progress
git stash push -m "WIP changes"
cd /path/to/repo
git wt remove work-in-progress

# Later, restore stash
git stash pop
```

#### Option 3: Force removal

```bash
git wt remove -f work-in-progress
```

**Warning**: Force removal discards uncommitted changes permanently.

### Issue: Configuration Not Recognized

**Symptom**:

```
# Configuration set but not applied
git config wt.basedir
# → .worktrees

# But worktrees created in current directory
```

**Cause**: Configuration scope issue (local vs global) or syntax error.

**Diagnosis**:

```bash
# Check configuration origin
git config --show-origin wt.basedir

# Check all wt.* configurations
git config --list | grep ^wt\.

# Verify syntax
cat .git/config
```

**Solutions**:

**Fix scope**:

```bash
# Remove global config
git config --global --unset wt.basedir

# Set local config
git config --local wt.basedir ".worktrees"
```

**Fix syntax** (in `.git/config`):

```ini
# Incorrect
[wt]
    basedir = .worktrees  # Missing quotes

# Correct
[wt]
    basedir = ".worktrees"
```

**Validate configuration**:

```bash
# Use diagnostic script
scripts/check-worktree-config.sh
```

### Issue: Shell Integration Not Working

**Symptom**:

```bash
# Command not found
git wt switch
# → bash: git-wt: command not found

# Or switch doesn't change directory
gwts
# → (no directory change)
```

**Cause**: Shell functions not loaded or `git-wt` not in PATH.

**Diagnosis**:

```bash
# Check if git-wt is installed
which git-wt

# Check if shell functions are loaded
type gwt
type gwts
```

**Solutions**:

**For git-wt command**:

```bash
# Check installation
mise list | grep git-wt

# Reinstall if needed
mise install go:github.com/k1LoW/git-wt@latest

# Verify PATH
echo $PATH | grep -o '[^:]*mise[^:]*'
```

**For Zsh functions**:

```bash
# Check if functions are loaded
grep -r "gwt" ~/.zshrc ~/.config/zsh/

# Source configuration manually
source ~/.config/zsh/config/tools/git.zsh

# Verify functions
type gwts
```

**Reload shell**:

```bash
exec zsh
```

### Issue: File Copying Not Working

**Symptom**:

```bash
git wt create feature/test --copy .env
# → .env file not copied to worktree
```

**Cause**: Source file doesn't exist or `--copy` syntax incorrect.

**Diagnosis**:

```bash
# Check if source file exists
ls -la .env

# Check current directory
pwd

# Verify git-wt version
git wt --version
```

**Solutions**:

**Fix file path**:

```bash
# Use absolute path
git wt create feature/test --copy /path/to/repo/.env

# Or use relative path from main repo
cd /path/to/repo
git wt create feature/test --copy .env
```

**Use configuration**:

```bash
# Set permanent copy files
git config wt.copyFiles ".env,.env.local"

# Create worktree (files copied automatically)
git wt create feature/test
```

**Manual copy as fallback**:

```bash
# Create worktree
git wt create feature/test

# Copy files manually
cp .env .worktrees/test/.env
```

### Issue: Hooks Not Executing

**Symptom**:

```bash
# Hook exists but doesn't execute
ls -la .git/hooks/post-worktree-add
# → -rw-r--r-- (not executable)
```

**Cause**: Hook file not executable or hooks disabled.

**Diagnosis**:

```bash
# Check executable bit
ls -la .git/hooks/post-worktree-add

# Check if hooks are enabled
git config wt.hooks.enabled
```

**Solutions**:

**Fix permissions**:

```bash
# Make hook executable
chmod +x .git/hooks/post-worktree-add
chmod +x .git/hooks/post-worktree-remove

# Verify
ls -la .git/hooks/post-worktree-*
```

**Enable hooks**:

```bash
# Check if disabled
git config wt.hooks.enabled

# Enable if disabled
git config wt.hooks.enabled true
```

**Verify hook execution**:

```bash
# Add debug output to hook
#!/bin/bash
echo "Hook executed: $0 $@" >> /tmp/worktree-hook.log
# ... rest of hook ...

# Create worktree and check log
git wt create test
cat /tmp/worktree-hook.log
```

### Issue: Worktree Path Conflicts

**Symptom**:

```
fatal: '/path/to/repo/.worktrees/feature' already exists
```

**Cause**: Target directory already exists (from previous worktree or manual creation).

**Solutions**:

#### Option 1: Remove existing directory

```bash
# Check if directory is a worktree
git wt list | grep feature

# If not a worktree, safe to remove
rm -rf .worktrees/feature

# Create worktree
git wt create feature/new-feature
```

#### Option 2: Use different path

```bash
# Specify custom path
git wt create feature/new-feature --path .worktrees/feature-v2
```

#### Option 3: Force creation

```bash
# Force overwrite (dangerous)
git wt create -f feature/new-feature
```

**Warning**: Force creation may lose data in existing directory.

## Performance Issues

### Issue: Slow Worktree Creation

**Symptom**: `git wt create` takes several minutes.

**Causes**:

- Large repository
- Slow disk I/O
- Post-add hook running heavy operations

**Diagnosis**:

```bash
# Time the operation
time git wt create test

# Check hook execution time
time .git/hooks/post-worktree-add .worktrees/test test
```

**Solutions**:

**Optimize hooks**:

```bash
# Make hooks faster
# - Run npm install in background
# - Skip unnecessary operations
# - Cache dependencies

# Example optimized hook
#!/bin/bash
WORKTREE_PATH=$1

cd "$WORKTREE_PATH"

# Run in background
(npm install > /dev/null 2>&1) &

# Don't wait for completion
```

**Use `--no-checkout`**:

```bash
# Skip checkout for faster creation
git wt create --no-checkout feature/test

# Checkout later
cd .worktrees/test
git checkout feature/test
```

**Disable hooks temporarily**:

```bash
git config wt.hooks.enabled false
git wt create feature/test
git config wt.hooks.enabled true
```

### Issue: Excessive Disk Usage

**Symptom**: Multiple worktrees consuming too much disk space.

**Cause**: Each worktree has its own `node_modules` or build artifacts.

**Solutions**:

**Share node_modules** (symlink approach):

```bash
# Create shared node_modules
mkdir -p .cache/node_modules
cd .cache
npm install

# Symlink in each worktree
cd /path/to/repo/.worktrees/feature-a
rm -rf node_modules
ln -s ../../.cache/node_modules node_modules
```

**Clean up build artifacts**:

```bash
# Add to post-remove hook
#!/bin/bash
WORKTREE_PATH=$1

# Clean build artifacts
rm -rf "$WORKTREE_PATH/dist"
rm -rf "$WORKTREE_PATH/.next"
rm -rf "$WORKTREE_PATH/build"
```

**Use workspace feature** (for monorepos):

```bash
# package.json (root)
{
  "workspaces": [
    ".worktrees/*"
  ]
}
```

## Git Internal Issues

### Issue: Corrupted Worktree Metadata

**Symptom**:

```
fatal: not a git repository: '/path/to/repo/.git/worktrees/broken'
```

**Cause**: Corrupted worktree metadata in `.git/worktrees/`.

**Solution**:

```bash
# Repair worktree
git wt repair broken

# If repair fails, manual cleanup
rm -rf .git/worktrees/broken
rm -rf .worktrees/broken

# Recreate if needed
git wt create -b existing-branch
```

### Issue: Detached HEAD in Worktree

**Symptom**: Worktree shows detached HEAD unexpectedly.

**Diagnosis**:

```bash
cd .worktrees/feature-a
git status
# → HEAD detached at abc123
```

**Solution**:

```bash
# Checkout branch
git checkout feature/feature-a

# Or create new branch from current state
git checkout -b feature/feature-a-recovered
```

### Issue: Upstream Tracking Lost

**Symptom**: Push fails because upstream not set.

**Solution**:

```bash
cd .worktrees/feature-a

# Set upstream
git branch --set-upstream-to=origin/feature/feature-a

# Or push with -u
git push -u origin feature/feature-a
```

**Prevention**: Enable auto-setup remote.

```bash
git config wt.autoSetupRemote true
```

## Diagnostic Tools

### Check Configuration

```bash
# Run diagnostic script
scripts/check-worktree-config.sh

# Manual checks
git config --list | grep ^wt\.
git config --show-origin wt.basedir
```

### List All Worktrees

```bash
# Simple list
git wt list

# Detailed list
git worktree list -v

# Show hidden details
cat .git/worktrees/*/gitdir
```

### Verify Worktree Integrity

```bash
# Check all worktrees
for wt in .git/worktrees/*; do
  name=$(basename "$wt")
  echo "Checking $name..."

  # Check if directory exists
  gitdir=$(cat "$wt/gitdir")
  if [ ! -d "$gitdir" ]; then
    echo "  ERROR: Directory not found"
  else
    echo "  OK"
  fi
done
```

### Clean Up Stale Worktrees

```bash
# Prune stale metadata
git worktree prune -v

# Remove orphaned directories
find .worktrees -maxdepth 1 -type d | while read dir; do
  name=$(basename "$dir")
  if ! git wt list | grep -q "$name"; then
    echo "Orphaned directory: $dir"
    # rm -rf "$dir"  # Uncomment to remove
  fi
done
```

## Prevention Best Practices

### Always Use git wt Commands

```bash
# ✅ Correct
git wt create feature/test
git wt remove feature/test

# ❌ Incorrect
mkdir .worktrees/test
rm -rf .worktrees/test
```

### Regular Maintenance

```bash
# Weekly cleanup script
#!/bin/bash
# cleanup-worktrees.sh

echo "Pruning stale worktrees..."
git worktree prune -v

echo "Listing remaining worktrees..."
git wt list

echo "Cleanup completed"
```

### Use Version Control for Configuration

```bash
# Commit git configuration
git add .git/config
# Note: .git/config is not normally tracked, use separate config file

# Or document in README
cat > docs/worktree-setup.md <<EOF
# Worktree Setup

## Configuration

\`\`\`bash
git config wt.basedir ".worktrees"
git config wt.autoSetupRemote true
\`\`\`
EOF
```

### Team Guidelines

**Document worktree conventions**:

1. Always use `.worktrees/` as base directory
2. Use `git wt` commands only
3. Clean up worktrees after PR merge
4. Run `git worktree prune` regularly
5. Don't manually edit `.git/worktrees/`

## See Also

- [Command Reference](git-wt-commands.md)
- [Configuration Options](configuration.md)
- [Workflow Patterns](workflows.md)

## Emergency Recovery

### Nuclear Option: Reset Everything

**Warning**: This will remove ALL worktrees and their branches.

```bash
# Backup first
git worktree list > /tmp/worktrees-backup.txt

# Remove all worktrees
git worktree list | grep -v '(bare)' | awk '{print $1}' | while read wt; do
  git worktree remove --force "$wt"
done

# Prune metadata
git worktree prune

# Clean up directories
rm -rf .worktrees/*

# Verify
git worktree list
```

---

**Version**: 1.0.0
**Last Updated**: 2026-02-14
