---
paths: ssh/**/*, docs/tools/ssh.md
source: docs/tools/ssh.md
---

# SSH Rules

Purpose: enforce secure SSH configuration hierarchy. Scope: config locations, include order, 1Password integration, and security best practices.

Detailed Reference: See [docs/tools/ssh.md](../../../docs/tools/ssh.md) for comprehensive implementation guide, examples, and troubleshooting.

## SSH configuration

- Tracked configs under ~/.config/ssh/: `config` (Include entry), `config.d/common|macos|linux/*.sshconfig`, `templates/`, `README.md`. Precedence: `config.d/common/*` (alphanumeric) -> `macos`/`linux` `settings.sshconfig` (via `Match exec`) -> local overrides under `~/.ssh/`. Platform-specific settings: see [docs/tools/ssh.md §プラットフォーム固有設定](../../../docs/tools/ssh.md#プラットフォーム固有設定).
- 1Password SSH agent is optional; enable by uncommenting IdentityAgent lines when available.
- Security: use ed25519 keys; permissions 700 on ~/.ssh and ~/.config/ssh, 644 on configs, 600 on private keys.
- Host onboarding: choose the right config.d file, set HostName/User/Port, test with `ssh -T hostname`; for GitHub behind firewall use Host github.com with Port 443.
- Maintenance: prune stale sockets in ~/.ssh/sockets (e.g., find -mtime +1 -delete); validate with `ssh -vvv` for debug and `ssh-add -l` for agent status.
