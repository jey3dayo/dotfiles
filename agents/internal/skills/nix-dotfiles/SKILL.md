---
name: nix-dotfiles
description: |
  [What] Dotfiles management and troubleshooting using Home Manager and Nix Flake. Supports configuration apply, generation management, diagnostics, and Agent Skills addition.
  [When] Use when: users say "skills not distributed", "~/.claude/skills/ is empty", "deploy dotfiles", "apply configuration", "test Nix flake", "home-manager", "generations", "rollback", "worktree not found", "スキルが配布されない"、"~/.claude/skills/ が空"、"dotfiles をデプロイ"、"設定を適用"、"Nix flake をテスト"、"home-manager"、"generations"、"rollback"、"worktree が見つからない".
  [Keywords] home-manager, nix flake, dotfiles, agent skills, generations, rollback, worktree, flake inputs, diagnosis, skill distribution
---

# nix-dotfiles - Home Manager Dotfiles Management

## Overview

An integrated skill for dotfiles management using Home Manager and Nix Flake. Covers everything from configuration apply to troubleshooting.

### Key Features

- Configuration apply (home-manager switch)
- Generation management (generations, rollback)
- Diagnostics (skill distribution, Flake inputs, Worktree detection, .gitignore)
- Agent Skills addition (flake inputs sync)

## Quick Start

### Most Common Operations

#### Apply Configuration

```bash
# Basic form (auto environment detection: CI/Pi/Default)
home-manager switch --flake ~/.config --impure

# Verify with dry-run
home-manager switch --flake ~/.config --impure --dry-run
```

### Verify Success

```bash
# Check if Agent Skills are distributed
ls -la ~/.claude/skills/

# Check symlinks for configuration files
readlink ~/.config/nvim
```

### Environment Detection

- CI: `mise.ci.toml`
- Pi: `mise.pi.toml`
- Default: `mise.toml`

#### Check and Rollback Generations

```bash
# List generations (latest 5)
home-manager generations | head -5

# Roll back to a specific generation
home-manager switch --generation <N>
```

#### Run Diagnostics

```bash
# Integrated diagnostic script
~/.config/agents/internal/skills/nix-dotfiles/scripts/diagnose.sh

# Individual checks
readlink ~/.claude/skills
nix flake metadata ~/.config
home-manager generations | head -3
```

### Basic Configuration Change Flow

```
Edit → Build Verify → Apply → Confirm
  ↓         ↓          ↓       ↓
 edit    build       switch  verify
```

### Example

```bash
# 1. Edit configuration file
nvim ~/.config/nix/dotfiles-module.nix

# 2. Build verification (without applying)
home-manager build --flake ~/.config --impure

# 3. Apply
home-manager switch --flake ~/.config --impure

# 4. Verify
ls -la ~/.config/<tool-name>
<tool> --version
```

## Core Workflows

### Decision Flow for Adding New Tools

Decision tree when adding a new tool:

```
[Q1] Does it generate or update files at runtime?
├─ Yes → [Q2] Are generated files excluded by .gitignore?
│          ├─ Yes → [Action A] Manage static files only
│          └─ No  → [Action B] Exclude entire directory
└─ No  → [Action C] Manage entire directory
```

#### Action A: Manage Static Files Only

### Examples

### Implementation

```nix
# nix/dotfiles-files.nix
xdgConfigFiles = [
  "mise/config.toml"
  "mise/mise.toml"
  "tmux/tmux.conf"
  "tmux/copy-paste.conf"
];
```

### Copy dynamic content via activation script

```nix
home.activation.dotfiles-mise = lib.hm.dag.entryAfter ["writeBoundary"] ''
  mise_config_dir="${config.xdg.configHome}/mise"
  mkdir -p "$mise_config_dir"
  if [ -d "${cleanedRepo}/mise/tasks" ]; then
    cp -r "${cleanedRepo}/mise/tasks" "$mise_config_dir/"
  fi
'';
```

#### Action B: Exclude Entire Directory

### Examples

### Reasons

- `gh/hosts.yml` (OAuth credentials)
- `karabiner/automatic_backups/` (automatic backups)
- `zed/cache/`, `zed/logs/` (cache and logs)

### Implementation

```gitignore
# .gitignore
gh/hosts.yml
karabiner/automatic_backups/
zed/cache/
zed/logs/
```

### Combine with Action A when static files are needed

```nix
xdgConfigFiles = [
  "gh/config.yml"  # static config only
];
```

#### Action C: Manage Entire Directory

### Examples

### Reasons

### Implementation

```nix
# nix/dotfiles-files.nix
xdgConfigDirs = [
  "alacritty"
  "wezterm"
  "nvim"
];
```

### Agent Skills Addition Flow

Steps to add a new Agent Skill source:

#### 1. Update agent-skills-sources.nix

```nix
# nix/agent-skills-sources.nix
{
  # existing skills...

  new-skill-source = {
    url = "github:org/repo";
    flake = false;
    baseDir = "skills";  # or repository root "."
    selection.enable = [ "skill-name" ];
  };
}
```

#### 2. Add to inputs in flake.nix (manual sync required)

```nix
# flake.nix
{
  inputs = {
    # ... existing inputs
    new-skill-source = {
      url = "github:org/repo";  # must match agent-skills-sources.nix
      flake = false;
    };
  };
}
```

### Important

#### 3. Verify

```bash
# Confirm Flake evaluation succeeds
nix flake show ~/.config

# Check if new input is recognized
nix flake metadata ~/.config | grep new-skill-source

# Home Manager build
home-manager build --flake ~/.config --impure --dry-run
```

#### 4. Verify Skill Distribution

```bash
# Apply
home-manager switch --flake ~/.config --impure

# Confirm skill was distributed
ls -la ~/.claude/skills/ | grep <skill-name>
```

## Diagnostic Commands

### Integrated Diagnostic Script

```bash
~/.config/agents/internal/skills/nix-dotfiles/scripts/diagnose.sh
```

### Check Items

1. Generation validation: Confirm existence of latest generation and presence of `.claude`
2. Symlink validation: Verify link targets of `~/.config/result` and `~/.claude/skills/`
3. Flake Inputs consistency: Confirm URL match between `flake.nix` and `agent-skills-sources.nix`
4. Worktree detection: Validate `DOTFILES_WORKTREE` and candidate paths

### Output Format

```
[✓] Generation check: Latest generation found
[✓] Symlink check: All symlinks valid
[✗] Flake inputs check: URL mismatch found
[✓] Worktree check: ~/.config detected
```

### Manual Diagnostic Commands

#### Check Generations

```bash
# Check latest generation
home-manager generations | head -3

# Check if .claude is included in generation
find /nix/store/<hash>-home-manager-generation/home-files/ -path "*claude*"

# Verify link generation with dry-run
home-manager switch --flake ~/.config --impure --dry-run 2>&1 | grep claude
```

#### Symlink Validation

```bash
# Check ~/.config/result
readlink ~/.config/result

# Link target of ~/.claude/skills/
readlink ~/.claude/skills

# List skills in Nix store
ls -la $(readlink ~/.claude/skills)
```

#### Flake metadata

```bash
# Check Flake information
nix flake metadata ~/.config

# List inputs
nix flake show ~/.config

# Check URL of specific input
nix flake metadata ~/.config | grep -E "(openai-skills|vercel)"
```

### Tool Selection Guide

| Tool                 | Purpose                           | When to Run             |
| -------------------- | --------------------------------- | ----------------------- |
| `diagnose.sh`        | Diagnose Home Manager integration | On trouble              |
| `nix run .#validate` | Validate skill structure          | After adding skill      |
| `nix flake check`    | Validate Flake syntax             | After editing flake.nix |
| `mise run ci`        | Full CI checks                    | Before creating PR      |

## Common Issues & Quick Fixes

### Skill Distribution Issues

### Symptoms

### Quick Diagnostics

```bash
~/.config/agents/internal/skills/nix-dotfiles/scripts/diagnose.sh
```

### Causes and Fixes

1. Ran switch from a different flake
   - Generation was overwritten
   - Fix: Run switch again from `~/.config`

     home-manager switch --flake ~/.config --impure

     ```

     ```

2. Inconsistency between flake.nix and agent-skills-sources.nix
   - URL/flake attributes do not match
   - Check:

     ```bash
     # URL list in agent-skills-sources.nix
     rg 'url = ' ~/.config/nix/agent-skills-sources.nix

     # URL list of inputs in flake.nix
     rg 'url = "github:.*skills' ~/.config/flake.nix
     ```

   - Fix: Manually sync mismatched entries (agent-skills-sources.nix → flake.nix)

3. Misconfigured selection.enable
   - Skill name does not exist in catalog, or typo

   - Check:

     ```bash

     mise run skills:report
     ```

   - Fix: Correct `selection.enable` in `nix/agent-skills-sources.nix`

### Details

### Flake inputs Error

### Symptoms

### Cause

### Diagnostic Steps

```bash
# Check inputs section
rg "inputs\s*=" ~/.config/flake.nix -A 10

# Check usage of let-in or import
rg "(let|import).*agent-skills" ~/.config/flake.nix
```

### Fix

1. Change inputs to static literal definitions (remove `let-in`)
2. Sync URL/flake between agent-skills-sources.nix and flake.nix
3. Verify with `nix flake show ~/.config`

### Details

### Worktree Detection Failure

### Symptoms

```
Error: Dotfiles repository not found
```

### Resolution

```bash
# Temporary override
DOTFILES_WORKTREE=/path/to/dotfiles home-manager switch --flake ~/.config --impure
```

### Permanent Configuration

```nix
# nix/dotfiles-module.nix
programs.dotfiles = {
  enable = true;
  repoPath = ./.;
  repoWorktreeCandidates = [
    "/custom/path/to/dotfiles"
    "${config.home.homeDirectory}/my-dotfiles"
  ];
};
```

### Details

### Write Errors

### Symptoms

```
Error: Permission denied
Error: Read-only file system
```

### Cause

### Fix

1. Remove the affected directory from `xdg.dirs` in `nix/dotfiles-files.nix`
2. Run `home-manager switch --flake ~/.config --impure`
3. It will be restored as a real directory
4. Manage only necessary static files individually via `xdg.files`

### Example

```nix
# Remove from xdg.dirs
# xdgConfigDirs = [ "gh" ];  # ← delete

# Manage only static files individually
xdgConfigFiles = [
  "gh/config.yml"  # static config only
];
```

## References Navigation

Detailed documentation is located in references/.

### references/troubleshooting.md

Detailed diagnostic procedures (symptoms → cause → check → fix)

### Main Sections

- Agent Skills not being distributed
- Flake inputs error
- Worktree detection failure
- .gitignore filtering issues
- Write errors

### references/commands.md

Full command reference (home-manager, nix flake, nix run)

### Coverage

- `home-manager switch`, `build`, `generations`, `switch --generation`
- `nix flake show`, `metadata`, `check`
- `nix run .#validate`
- Diagnostic commands (generation check, symlink validation, flake inputs check)

### references/architecture.md

Flake structure, Worktree SSoT, gitignore filtering, glossary

### Main Sections

- Glossary (Worktree, Activation Script, DAG, SSoT, cleanedRepo)
- Flake structure
- Flake Inputs and Agent Skills management
- Worktree detection logic
- .gitignore-aware filtering
- Static vs dynamic file management
- Activation Scripts

## Scripts Usage

### diagnose.sh

Integrated diagnostic script. Performs 4 checks:

### Check Items

1. Generation validation
   - Confirm latest generation exists
   - Confirm `~/.claude/skills/` is included
   - Within 24 hours check (warning)

2. Symlink validation
   - `~/.config/result` is a valid symlink
   - Link target matches latest generation
   - Link target of `~/.claude/skills/`

3. Flake Inputs consistency
   - Number of inputs in `flake.nix`
   - Number of sources in `nix/agent-skills-sources.nix`
   - URL diff detection

4. Worktree detection
   - `DOTFILES_WORKTREE` environment variable
   - Check existence of default candidate paths
   - Confirm `flake.nix`, `home.nix`, `nix/dotfiles-module.nix` for each candidate

### Run

```bash
~/.config/agents/internal/skills/nix-dotfiles/scripts/diagnose.sh
```

### Output Format

```
[✓] Check name: message
[✗] Check name: message

All checks passed ✓
```

or

```
Some checks failed. See details above.
```
