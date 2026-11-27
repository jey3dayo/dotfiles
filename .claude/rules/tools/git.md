---
paths:
  - "git/**/*"
  - "docs/tools/git.md"
source: docs/tools/git.md
---

# Git Rules

Purpose: enforce configuration hierarchy for Git with secure overrides. Scope: config locations, include order, worktree hooks, 1Password integration, and add/diagnose workflows.

Detailed Reference: See [docs/tools/git.md](../../../docs/tools/git.md) for comprehensive implementation guide, examples, and troubleshooting.

## Git configuration

- The configuration entry point is `git/config`. [`shell/env.sh`](../../../shell/env.sh) sets `GIT_CONFIG_GLOBAL` to `$XDG_CONFIG_HOME/git/config`. Other tracked files include `alias.gitconfig`, `diff.gitconfig`, `ghq.gitconfig`, optional `1password.gitconfig`, `attributes`, `local.gitconfig` sample, `hooks/post-checkout` (`init.templateDir`), and `wt-hook.sh` (`wt.hook`).
- Load order in `git/config` (later wins): feature includes (`diff`/`ghq`/`alias`) -> `git/config` body -> `~/.gitconfig_local`.
- Personal/work overrides belong only in `~/.gitconfig_local`. Use `git config --global --add include.path ~/.config/git/1password.gitconfig` if enabling 1Password signing.
- Verification: `git config --list --show-origin` and `git config user.name` to confirm overrides.
