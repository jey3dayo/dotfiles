---
paths: git/**/*, docs/tools/git.md
source: docs/tools/git.md
---

# Git Rules

Purpose: enforce configuration hierarchy for Git with secure overrides. Scope: config locations, include order, 1Password integration, and add/diagnose workflows.

**Detailed Reference**: See [docs/tools/git.md](../../docs/tools/git.md) for comprehensive implementation guide, examples, and troubleshooting.

## Git configuration

- All tracked configs live in ~/.config/git/. Main files: config (linked to ~/.gitconfig), alias.gitconfig, diff.gitconfig, ghq.gitconfig, optional 1password.gitconfig, attributes, and local.gitconfig sample.
- Load order (later wins): config -> feature includes (diff/ghq/alias) -> ~/.gitconfig_local.
- Personal/work overrides belong only in ~/.gitconfig_local. Use `git config --global --add include.path ~/.config/git/1password.gitconfig` if enabling 1Password signing.
- Verification: `git config --list --show-origin` and `git config user.name` to confirm overrides; dry-run commits to test signing.
