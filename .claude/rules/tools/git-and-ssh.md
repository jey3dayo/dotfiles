---
paths: git/**/*, ssh/**/*, docs/tools/git.md, docs/tools/ssh.md
---

# Git and SSH Rules

Purpose: enforce configuration hierarchy for Git and SSH with secure overrides. Scope: config locations, include order, 1Password integration, and add/diagnose workflows.
Sources: docs/tools/git.md, docs/tools/ssh.md.

## Cross-cutting rules

- Keep tracked Git config in `~/.config/git/` and tracked SSH config in `~/.config/ssh/`. Personal or sensitive overrides stay outside the repo (`~/.gitconfig_local`, `~/.ssh/`).
- Respect config layering instead of duplicating values: Git feature includes feed into `~/.gitconfig_local`, and SSH common/platform modules feed into local overrides.
- 1Password integration is optional for both Git signing and SSH agent usage. Enable it through the documented include or `IdentityAgent` hooks rather than ad hoc edits.
- Verify Git changes with `git config --list --show-origin` and `git config user.name`. Verify SSH changes with `ssh -T`, `ssh -vvv`, and `ssh-add -l`.
- For GitHub access behind restrictive networks, keep the documented SSH fallback on port 443 rather than inventing repo-local exceptions.
- Detailed file layouts and platform-specific SSH branching belong in [docs/tools/git.md](../../docs/tools/git.md) and [docs/tools/ssh.md](../../docs/tools/ssh.md).
