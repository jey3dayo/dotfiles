---
paths: ssh/**/*, docs/tools/ssh.md
source: docs/tools/ssh.md
---

# SSH Rules

Purpose: enforce secure SSH configuration hierarchy. Scope: config locations, include order, 1Password integration, and security best practices.

Detailed Reference: See [docs/tools/ssh.md](../../../docs/tools/ssh.md) for comprehensive implementation guide, examples, and troubleshooting.

## SSH configuration

### File structure

- Tracked configs under ~/.config/ssh/: config, config.d/common/00-global.sshconfig, config.d/common/01-1password.sshconfig, config.d/common/10-dev-services.sshconfig, config.d/common/20-home-network.sshconfig, config.d/macos/settings.sshconfig, config.d/linux/settings.sshconfig, templates/, README.
- Local sensitive data stays under ~/.ssh/ (ssh_config.d, sockets). Precedence: 00-global -> 01-1password -> 10-dev-services -> 20-home-network -> macos/settings -> linux/settings -> local overrides.
- `00-global.sshconfig` is the single source for global SSH settings.

### Platform-specific settings

#### macOS (config.d/macos/settings.sshconfig)

- macOS-specific settings (UseKeychain, OrbStack, Colima) managed via ssh/config.d/macos/settings.sshconfig
- Git managed (committed): setup.sh実行後すぐに設定反映
- Match exec判定: 判定自体は ssh/config 側で `Match exec "uname -s | grep -q Darwin"` として宣言され、成立時のみ `config.d/macos/*` を Include する（macos/settings.sshconfig 自体には Match exec は書かれていない）
- Linux/WSL2: ファイルは存在するがMatch失敗により設定無視（エラーなし）
- OrbStack/Colima: config.d/macos/settings.sshconfig内でコメントアウトされた Include（未有効化）として用意されている

#### Linux/WSL2 (config.d/linux/settings.sshconfig)

- Linux/WSL2-specific settings managed via ssh/config.d/linux/settings.sshconfig
- Currently empty placeholder for future extensions
- Match exec判定: 判定自体は ssh/config 側で `Match exec "uname | grep -qi linux"` として宣言され、成立時のみ `config.d/linux/*` を Include する（linux/settings.sshconfig 自体には Match exec は書かれていない）
- WSL2判定: `Match exec "uname -r | grep -qi microsoft"` は linux/settings.sshconfig 内にコメントアウトされた例として存在するのみで、現状は有効化されていない
- macOS: ファイルは存在するがMatch失敗により設定無視（エラーなし）

### Security and maintenance

- 1Password SSH agent is optional; enable by uncommenting IdentityAgent lines when available.
- Security: use ed25519 keys; permissions 700 on ~/.ssh and ~/.config/ssh, 644 on configs, 600 on private keys.
- Host onboarding: choose the right config.d file, set HostName/User/Port, test with `ssh -T hostname`; for GitHub behind firewall use Host github.com with Port 443.
- Maintenance: prune stale sockets in ~/.ssh/sockets (e.g., find -mtime +1 -delete); validate with `ssh -vvv` for debug and `ssh-add -l` for agent status.
