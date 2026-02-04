---
paths: git/**/*, ssh/**/*, docs/tools/git.md, docs/tools/ssh.md
---

# Git and SSH Rules

Purpose: enforce configuration hierarchy for Git and SSH with secure overrides. Scope: config locations, include order, 1Password integration, and add/diagnose workflows.
Sources: docs/tools/git.md, docs/tools/ssh.md.

## Git configuration

- All tracked configs live in ~/.config/git/. Main files: config (linked to ~/.gitconfig), alias.gitconfig, diff.gitconfig, ghq.gitconfig, optional 1password.gitconfig, attributes, and local.gitconfig sample.
- Load order (later wins): config -> feature includes (diff/ghq/alias) -> ~/.gitconfig_local.
- Personal/work overrides belong only in ~/.gitconfig_local. Use `git config --global --add include.path ~/.config/git/1password.gitconfig` if enabling 1Password signing.
- Verification: `git config --list --show-origin` and `git config user.name` to confirm overrides; dry-run commits to test signing.

## SSH configuration

### Directory structure

```
~/.config/ssh/
├── config (main config file)
└── config.d/
    ├── common/          # Cross-platform settings
    │   ├── 00-global.sshconfig
    │   ├── 01-1password.sshconfig
    │   ├── 10-dev-services.sshconfig
    │   └── 20-home-network.sshconfig
    ├── macos/           # macOS-specific settings
    │   └── settings.sshconfig
    └── linux/           # Linux/WSL2-specific settings
        └── settings.sshconfig
```

- Tracked configs under ~/.config/ssh/: config, config.d/{common,macos,linux}/\*.
- Local sensitive data stays under ~/.ssh/ (ssh_config.d, sockets).
- Load order: IgnoreUnknown declaration -> common/_ (alphanumeric: 00->01->10->20) -> platform-specific (macos/_ or linux/\* via Match exec) -> local overrides.
- 1Password SSH agent is optional; enable by uncommenting IdentityAgent lines when available.
- Security: use ed25519 keys; permissions 700 on ~/.ssh and ~/.config/ssh, 644 on configs, 600 on private keys.
- Host onboarding: choose the right config.d/common file, set HostName/User/Port, test with `ssh -T hostname`; for GitHub behind firewall use Host github.com with Port 443.
- Maintenance: prune stale sockets in ~/.ssh/sockets (e.g., find -mtime +1 -delete); validate with `ssh -vvv` for debug and `ssh-add -l` for agent status.

### Platform-specific settings

**Architecture**: Directory-based organization with conditional Include and `IgnoreUnknown` for cross-platform compatibility.

**macOS (config.d/macos/settings.sshconfig)**:

- macOS-specific settings (UseKeychain, AddKeysToAgent, OrbStack, Colima) managed via config.d/macos/settings.sshconfig
- Git managed (committed): fixed file always present in repository, no setup.sh generation needed
- Cross-platform compatibility: `IgnoreUnknown UseKeychain` declared in main config allows Linux to safely ignore unrecognized macOS directives
- Conditional Include: `Match exec "uname -s | grep -q Darwin"` in main config includes macos/\* only on macOS
- Linux/WSL2: Directory exists but not included due to Match exec failure (no error)
- OrbStack/Colima: Optional Include directives in settings.sshconfig (commented out by default)

**Linux/WSL2 (config.d/linux/settings.sshconfig)**:

- Linux/WSL2-specific settings managed via config.d/linux/settings.sshconfig
- Git managed (committed): fixed file always present in repository, no setup.sh generation needed
- Currently empty placeholder for future extensions
- Conditional Include: `Match exec "uname | grep -qi linux"` in main config includes linux/\* only on Linux
- WSL2 refinement: Nested `Match exec "uname -r | grep -qi microsoft"` available for WSL2-only settings (commented out)
- macOS: Directory exists but not included due to Match exec failure (no error)

### Configuration consolidation

- Common settings consolidated into config.d/common/ directory (00-global, 01-1password, 10-dev-services, 20-home-network)
- Platform-specific settings separated into config.d/macos/ and config.d/linux/
- Wildcard Include (`common/*`) for easy maintenance with alphanumeric ordering
- Single source for all global SSH settings
