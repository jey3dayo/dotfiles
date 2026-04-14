---
paths: docs/tools/1password.md, zsh/config/tools/1password.zsh, powershell/profile.d/env.ps1, scripts/setup-env.ps1, scripts/setup-env.sh
source: docs/tools/1password.md
---

# 1Password Rules

Purpose: enforce 1Password CLI usage, service account boundaries, and token storage practices. Scope: dotenv key retrieval, token rotation, and automation-safe vault usage.

Detailed Reference: See [docs/tools/1password.md](../../docs/tools/1password.md) for the full operational guide and rotation steps.

## Authentication modes

- Use desktop app integration for human, interactive `op` usage.
- Use `OP_SERVICE_ACCOUNT_TOKEN` for automation and non-interactive agent flows.
- Do not rely on service accounts to access built-in vaults such as `Private`, `Personal`, or `Employee`.

## Vault and item rules

- Automation secrets belong in the normal vault `Dotfiles Automation`.
- The dotenv private key item is `.env.keys | dotfiles` with item ID `mzy4lhfwqbtbtr3rm466qhrouq`.
- Keep user-facing restore hints aligned with the current item title and vault name.

## Token handling

- Never store `OP_SERVICE_ACCOUNT_TOKEN` in `dotenvx`-managed `.env` files.
- Persist the token only in `~/.config/op/service-account-token` via the helper functions.
- Rotate tokens by overwriting the local token file and invalidating the old token or service account in 1Password.

## Shell integration

- PowerShell loads the token from `powershell/profile.d/env.ps1`.
- Zsh loads the token from `zsh/config/tools/1password.zsh`.
- When `OP_SERVICE_ACCOUNT_TOKEN` is present, avoid forcing `--account`; only pass `--account` for app-integration flows.
