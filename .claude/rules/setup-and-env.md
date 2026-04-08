---
paths: docs/setup.md, flake.nix, home.nix, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json, windows/setup.ps1, powershell/profile.ps1
---

# Setup and Environment Rules

Purpose: enforce the single source for onboarding steps and verification. Scope: initial clone, required tools, and validation commands.
Sources: docs/setup.md.

## Setup flow (macOS/Linux/WSL2)

- Clone repo to ~/.config and enter the directory.
- Create ~/.gitconfig_local with user name/email before running setup.
- Install Homebrew first if missing using the official install script.
- Run `brew bundle` to install dependencies.
- Run `home-manager switch --flake ~/.config --impure` to apply dotfiles configuration.
- Restart shell via `exec zsh`.

Note: Home Manager manages dotfiles deployment. Environment is auto-detected (CI > Raspberry Pi > Default).

## Setup flow (Windows)

- Clone repo to `~/.config` and enter the directory.
- Run `powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1`.
- Treat `~/.config/powershell/profile.ps1` as the source of truth for PowerShell.
- `Documents\PowerShell` and `Documents\WindowsPowerShell` are generated bridge entrypoints that only dot-source the repo profile.
- When only the bridge files need refresh, run `powershell -ExecutionPolicy Bypass -File .\windows\setup.ps1 -ProfilesOnly`.

## Verification

- `zsh-help` and `zsh-help tools` confirm shell configuration and tool availability.
- `nvim` first run installs plugins; `git config user.name` should reflect local override.
- Post-setup health: `mise run ci` to mirror CI checks.

## Environment notes

- Work-specific Git config stays in ~/.gitconfig_local.
- SSH keys: generate ed25519 with `ssh-keygen -t ed25519 -C "email@example.com"` if needed.
- Terminal: WezTerm auto-loads config; restart Alacritty after changes.
