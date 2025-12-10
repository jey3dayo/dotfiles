# Git and SSH Rules

Purpose: enforce configuration hierarchy for Git and SSH with secure overrides. Scope: config locations, include order, 1Password integration, and add/diagnose workflows.
Sources: docs/tools/git.md, docs/tools/ssh.md.

## Git configuration
- All tracked configs live in ~/.config/git/. Main files: config (linked to ~/.gitconfig), alias.gitconfig, diff.gitconfig, ghq.gitconfig, optional 1password.gitconfig, attributes, and local.gitconfig sample.
- Load order (later wins): config -> feature includes (diff/ghq/alias) -> ~/.gitconfig_local.
- Personal/work overrides belong only in ~/.gitconfig_local. Use `git config --global --add include.path ~/.config/git/1password.gitconfig` if enabling 1Password signing.
- Verification: `git config --list --show-origin` and `git config user.name` to confirm overrides; dry-run commits to test signing.

## SSH configuration
- Tracked configs under ~/.config/ssh/: config, config.d/00-global/01-1password/10-dev-services/20-home-network/99-defaults, templates/, README.
- Local sensitive data stays under ~/.ssh/ (ssh_config.d, sockets). Precedence: 00-global -> 01-1password -> 10-dev-services -> 20-home-network -> 99-defaults -> local overrides.
- 1Password SSH agent is optional; enable by uncommenting IdentityAgent lines when available.
- Security: use ed25519 keys; permissions 700 on ~/.ssh and ~/.config/ssh, 644 on configs, 600 on private keys.
- Host onboarding: choose the right config.d file, set HostName/User/Port, test with `ssh -T hostname`; for GitHub behind firewall use Host github.com with Port 443.
- Maintenance: prune stale sockets in ~/.ssh/sockets (e.g., find -mtime +1 -delete); validate with `ssh -vvv` for debug and `ssh-add -l` for agent status.
