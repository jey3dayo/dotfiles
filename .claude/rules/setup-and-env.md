---
paths: docs/setup.md, flake.nix, home.nix, .mise.toml, mise/config.toml, Brewfile, Brewfile.lock.json, windows/setup.ps1, powershell/profile.ps1
---

# Setup and Environment Rules

Purpose: enforce the single source for onboarding steps and verification. Scope: initial clone, required tools, and validation commands.
Sources: docs/setup.md.

## Core rules

- Follow `docs/setup.md` for all onboarding steps. Do not restate setup procedures elsewhere.
- Create `~/.gitconfig_local` before applying the environment so local identity stays outside the repo.
- On macOS/Linux/WSL2, treat Home Manager as the deployment path.
- On Windows, run `windows/setup.ps1`; keep `~/.config/powershell/profile.ps1` as the PowerShell source of truth and treat `Documents/*PowerShell` as generated bridge entrypoints.

## Verification

- Use the verification commands listed in `docs/setup.md`.
- Prefer `mise run ci` for post-setup health checks.
- Route tool-specific setup details to the corresponding `docs/tools/*.md` file.
