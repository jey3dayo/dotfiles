---
paths: ssh/**/*, docs/tools/ssh.md
source: docs/tools/ssh.md
---

# SSH Rules

Purpose: enforce secure SSH configuration hierarchy. Scope: config locations, include order, 1Password integration, and security best practices.

**Detailed Reference**: See [docs/tools/ssh.md](../../docs/tools/ssh.md) for comprehensive implementation guide, examples, and troubleshooting.

## SSH configuration

- Tracked configs under ~/.config/ssh/: config, config.d/00-global/01-1password/10-dev-services/20-home-network/99-defaults, templates/, README.
- Local sensitive data stays under ~/.ssh/ (ssh_config.d, sockets). Precedence: 00-global -> 01-1password -> 10-dev-services -> 20-home-network -> 99-defaults -> local overrides.
- 1Password SSH agent is optional; enable by uncommenting IdentityAgent lines when available.
- Security: use ed25519 keys; permissions 700 on ~/.ssh and ~/.config/ssh, 644 on configs, 600 on private keys.
- Host onboarding: choose the right config.d file, set HostName/User/Port, test with `ssh -T hostname`; for GitHub behind firewall use Host github.com with Port 443.
- Maintenance: prune stale sockets in ~/.ssh/sockets (e.g., find -mtime +1 -delete); validate with `ssh -vvv` for debug and `ssh-add -l` for agent status.
