# Git Worktree Configuration

Complete reference for all git-wt and git worktree configuration options.

## Configuration Levels

Git configuration can be set at three levels:

1. **System** (`/etc/gitconfig`): All users
2. **Global** (`~/.gitconfig`): Current user
3. **Local** (`.git/config`): Current repository (recommended)

```bash
# Set local config (recommended)
git config --local wt.basedir ".worktrees"

# Set global config
git config --global wt.basedir ".worktrees"

# Set system config (requires sudo)
sudo git config --system wt.basedir ".worktrees"
```

## git-wt Configuration (wt.\*)

### wt.basedir

Base directory for worktrees.

**Type**: String
**Default**: `.worktrees`
**Scope**: Local or Global

```bash
# Set base directory
git config wt.basedir ".worktrees"

# Alternative names
git config wt.basedir ".worktree"
git config wt.basedir "worktrees"
```

**Important**: When changing this value, also update:

- `.gitignore`
- `.fdignore`
- `.prettierignore`
- `mise/config.toml` (if using mise)

### wt.nameTemplate

Template for auto-generating worktree names from branch names.

**Type**: String (Go template)
**Default**: `{{.BranchName}}`
**Scope**: Local or Global

**Template Variables**:

- `{{.BranchName}}`: Full branch name (e.g., `feature/user-auth`)
- `{{.ShortBranchName}}`: Last component (e.g., `user-auth`)
- `{{.Prefix}}`: Branch prefix (e.g., `feature`)
- `{{.Timestamp}}`: Current timestamp (Unix)

**Examples**:

```bash
# Use short branch name only
git config wt.nameTemplate "{{.ShortBranchName}}"
# feature/user-auth → user-auth

# Include prefix
git config wt.nameTemplate "{{.Prefix}}-{{.ShortBranchName}}"
# feature/user-auth → feature-user-auth

# Add timestamp
git config wt.nameTemplate "{{.ShortBranchName}}-{{.Timestamp}}"
# feature/user-auth → user-auth-1707876543
```

### wt.copyFiles

Files to automatically copy to new worktrees.

**Type**: String (comma-separated)
**Default**: `` (empty)
**Scope**: Local or Global

```bash
# Copy .env file
git config wt.copyFiles ".env"

# Copy multiple files
git config wt.copyFiles ".env,config.local.json,.vscode/settings.json"
```

**Use Cases**:

- Environment files (`.env`, `.env.local`)
- Local configuration (`config.local.json`)
- Editor settings (`.vscode/settings.json`)
- IDE configuration (`.idea/workspace.xml`)

### wt.autoSetupRemote

Automatically set up remote tracking for new branches.

**Type**: Boolean
**Default**: `false`
**Scope**: Local or Global

```bash
# Enable auto-setup
git config wt.autoSetupRemote true
```

**Behavior**:
When `true`, new branches created with `git wt create` will automatically track their remote counterpart (if it exists).

### wt.defaultRemote

Default remote for new branches.

**Type**: String
**Default**: `origin`
**Scope**: Local or Global

```bash
# Set default remote
git config wt.defaultRemote "upstream"
```

### wt.checkoutAfterCreate

Automatically checkout worktree after creation.

**Type**: Boolean
**Default**: `true`
**Scope**: Local or Global

```bash
# Disable auto-checkout
git config wt.checkoutAfterCreate false
```

**Use Case**: When creating multiple worktrees in batch without switching to them.

### wt.pruneAfterRemove

Automatically prune worktree metadata after removal.

**Type**: Boolean
**Default**: `false`
**Scope**: Local or Global

```bash
# Enable auto-prune
git config wt.pruneAfterRemove true
```

### wt.lockReason

Default reason for locking worktrees.

**Type**: String
**Default**: `` (empty)
**Scope**: Local or Global

```bash
# Set default lock reason
git config wt.lockReason "Protected by CI/CD pipeline"
```

## Git Worktree Configuration (worktree.\*)

Native git worktree configuration options.

### worktree.guessRemote

Guess remote branch when creating worktree with existing branch name.

**Type**: Boolean
**Default**: `true`
**Scope**: Global or Local

```bash
# Enable guess remote
git config worktree.guessRemote true
```

**Example**:

```bash
# With guessRemote=true
git worktree add .worktrees/feature feature
# → Automatically uses origin/feature if it exists

# With guessRemote=false
git worktree add .worktrees/feature feature
# → Only uses local feature branch
```

## Hook Configuration

### wt.hooks.postAdd

Path to post-add hook script.

**Type**: String
**Default**: `.git/hooks/post-worktree-add`
**Scope**: Local

```bash
# Custom hook location
git config wt.hooks.postAdd "/usr/local/bin/worktree-init.sh"
```

### wt.hooks.postRemove

Path to post-remove hook script.

**Type**: String
**Default**: `.git/hooks/post-worktree-remove`
**Scope**: Local

```bash
# Custom hook location
git config wt.hooks.postRemove "/usr/local/bin/worktree-cleanup.sh"
```

### wt.hooks.enabled

Enable or disable hooks.

**Type**: Boolean
**Default**: `true`
**Scope**: Local or Global

```bash
# Disable hooks
git config wt.hooks.enabled false
```

## Shell Integration Configuration

### wt.shell.integration

Enable shell integration features.

**Type**: Boolean
**Default**: `true`
**Scope**: Global

```bash
# Enable shell integration
git config --global wt.shell.integration true
```

### wt.shell.cdAfterSwitch

Change directory after switching worktree.

**Type**: Boolean
**Default**: `true`
**Scope**: Global

```bash
# Enable auto-cd
git config --global wt.shell.cdAfterSwitch true
```

**Note**: Requires shell integration (Zsh functions).

### wt.shell.promptFormat

Format for shell prompt when in worktree.

**Type**: String
**Default**: `[wt:%s]`
**Scope**: Global

```bash
# Custom prompt format
git config --global wt.shell.promptFormat "⚙️ %s"
```

**Template Variables**:

- `%s`: Worktree name

## Interactive Mode Configuration

### wt.interactive.fuzzyFinder

Fuzzy finder command for interactive mode.

**Type**: String
**Default**: `fzf`
**Scope**: Global

```bash
# Use custom fuzzy finder
git config --global wt.interactive.fuzzyFinder "peco"
```

**Supported Finders**:

- `fzf` (recommended)
- `peco`
- `percol`
- `sk` (skim)

### wt.interactive.fuzzyFinderOptions

Options for fuzzy finder.

**Type**: String
**Default**: `--height=40% --reverse --border`
**Scope**: Global

```bash
# Custom fzf options
git config --global wt.interactive.fuzzyFinderOptions "--height=50% --reverse --border=rounded --preview='git log -1 {}'"
```

## Advanced Configuration

### wt.cleanup.autoRemoveUntracked

Automatically remove untracked files when deleting worktree.

**Type**: Boolean
**Default**: `false`
**Scope**: Local or Global

```bash
# Enable auto-removal of untracked files
git config wt.cleanup.autoRemoveUntracked true
```

**Warning**: This will delete untracked files without confirmation. Use with caution.

### wt.security.allowUnsafeOperations

Allow potentially unsafe operations (force delete, etc.).

**Type**: Boolean
**Default**: `false`
**Scope**: Local

```bash
# Allow unsafe operations (not recommended)
git config wt.security.allowUnsafeOperations true
```

### wt.performance.parallelCreate

Create worktrees in parallel (experimental).

**Type**: Integer
**Default**: `1` (sequential)
**Scope**: Local or Global

```bash
# Enable parallel creation (max 4 worktrees)
git config wt.performance.parallelCreate 4
```

**Note**: Experimental feature. May cause issues with hooks or file copying.

## Recommended Configuration

### Development (Local)

```bash
# Base directory
git config --local wt.basedir ".worktrees"

# Name template (short names)
git config --local wt.nameTemplate "{{.ShortBranchName}}"

# Copy environment files
git config --local wt.copyFiles ".env,.env.local"

# Auto-setup remote
git config --local wt.autoSetupRemote true

# Enable hooks
git config --local wt.hooks.enabled true
```

### Team (Global)

```bash
# Consistent base directory across team
git config --global wt.basedir ".worktrees"

# Simple name template
git config --global wt.nameTemplate "{{.BranchName}}"

# Enable shell integration
git config --global wt.shell.integration true
git config --global wt.shell.cdAfterSwitch true

# Interactive mode with fzf
git config --global wt.interactive.fuzzyFinder "fzf"
git config --global wt.interactive.fuzzyFinderOptions "--height=40% --reverse --border"
```

### CI/CD

```bash
# Minimal configuration for automation
git config --local wt.basedir "build-worktrees"
git config --local wt.hooks.enabled false
git config --local wt.checkoutAfterCreate false
```

## Configuration File (YAML)

git-wt also supports YAML configuration file.

**Location**: `~/.config/git-wt/config.yaml` or `$GIT_WT_CONFIG`

**Example**:

```yaml
# ~/.config/git-wt/config.yaml

basedir: .worktrees

nameTemplate: "{{.ShortBranchName}}"

copyFiles:
  - .env
  - .env.local
  - config.local.json

autoSetupRemote: true

hooks:
  enabled: true
  postAdd: .git/hooks/post-worktree-add
  postRemove: .git/hooks/post-worktree-remove

shell:
  integration: true
  cdAfterSwitch: true
  promptFormat: "[wt:%s]"

interactive:
  fuzzyFinder: fzf
  fuzzyFinderOptions: "--height=40% --reverse --border"

security:
  allowUnsafeOperations: false

performance:
  parallelCreate: 1
```

**Priority**: YAML config < Global git config < Local git config

## Troubleshooting Configuration

### View Current Configuration

```bash
# All wt.* config
git config --list | grep ^wt\.

# Specific config value
git config wt.basedir

# Show origin (local, global, system)
git config --show-origin wt.basedir
```

### Reset Configuration

```bash
# Remove local config
git config --local --unset wt.basedir

# Remove global config
git config --global --unset wt.basedir

# Remove entire section
git config --local --remove-section wt
```

### Validate Configuration

Use the diagnostic script:

```bash
scripts/check-worktree-config.sh
```

## See Also

- [Command Reference](git-wt-commands.md)
- [Workflow Patterns](workflows.md)
- [Troubleshooting](troubleshooting.md)

---

**Version**: 1.0.0 (git-wt 0.15.0+)
**Last Updated**: 2026-02-14
