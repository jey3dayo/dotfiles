# Setup and Environment Rules

Purpose: enforce the single source for onboarding steps and verification. Scope: initial clone, required tools, and validation commands.
Sources: docs/setup.md.

## Setup flow (macOS)
- Clone repo to ~/src/github.com/jey3dayo/dotfiles and enter the directory.
- Create ~/.gitconfig_local with user name/email before running setup.
- Run `sh ./setup.sh && brew bundle` for automated setup; restart shell via `exec zsh`.
- Install Homebrew first if missing using the official install script.

## Verification
- `zsh-help` and `zsh-help tools` confirm shell configuration and tool availability.
- `nvim` first run installs plugins; `git config user.name` should reflect local override.
- Post-setup health: `mise run ci` to mirror CI checks.

## Environment notes
- Work-specific Git config stays in ~/.gitconfig_local.
- SSH keys: generate ed25519 with `ssh-keygen -t ed25519 -C "email@example.com"` if needed.
- Terminal: WezTerm auto-loads config; restart Alacritty after changes.
