---
paths: ssh/**/*, docs/tools/ssh.md
source: docs/tools/ssh.md
---

# SSH Rules

Purpose: enforce secure SSH configuration hierarchy. Scope: config locations, include order, 1Password integration, and security best practices.

**Detailed Reference**: See [docs/tools/ssh.md](../../docs/tools/ssh.md) for comprehensive implementation guide, examples, and troubleshooting.

## SSH configuration

### File structure

- Tracked configs under ~/.config/ssh/: config, config.d/00-global/01-1password/10-dev-services/20-home-network/30-macos/31-linux, templates/, README.
- Local sensitive data stays under ~/.ssh/ (ssh_config.d, sockets). Precedence: 00-global -> 01-1password -> 10-dev-services -> 20-home-network -> 30-macos -> 31-linux -> local overrides.
- Configuration consolidation: Global settings consolidated into 00-global.sshconfig (previously split between 00-global and 99-defaults). Single source for all global SSH settings.

### Platform-specific settings

#### macOS (30-macos.sshconfig)

- macOS-specific settings (UseKeychain, OrbStack, Colima) managed via ssh/config.d/30-macos.sshconfig
- Git managed (committed): setup.sh実行後すぐに設定反映
- Match exec判定: `Match exec "uname | grep -qi darwin"` でmacOSのみ適用
- Linux/WSL2: ファイルは存在するがMatch失敗により設定無視（エラーなし）
- OrbStack/Colima: 30-macos.sshconfig内でMatch判定により条件付きInclude

#### Linux/WSL2 (31-linux.sshconfig)

- Linux/WSL2-specific settings managed via ssh/config.d/31-linux.sshconfig
- Currently empty placeholder for future extensions
- Match exec判定: `Match exec "uname | grep -qi linux"` でLinuxのみ適用
- WSL2判定: `Match exec "uname -r | grep -qi microsoft"` でWSL2のみ適用
- macOS: ファイルは存在するがMatch失敗により設定無視（エラーなし）

### Security and maintenance

- 1Password SSH agent is optional; enable by uncommenting IdentityAgent lines when available.
- Security: use ed25519 keys; permissions 700 on ~/.ssh and ~/.config/ssh, 644 on configs, 600 on private keys.
- Host onboarding: choose the right config.d file, set HostName/User/Port, test with `ssh -T hostname`; for GitHub behind firewall use Host github.com with Port 443.
- Maintenance: prune stale sockets in ~/.ssh/sockets (e.g., find -mtime +1 -delete); validate with `ssh -vvv` for debug and `ssh-add -l` for agent status.
