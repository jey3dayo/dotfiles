---
paths:
  - "~/.claude/config/claude-marketplace.toml"
  - "~/.claude/bin/claude-marketplace-sync.sh"
  - "~/.claude/**"
---

# Claude Code Rules

Purpose: maintain Claude Code marketplace plugin management and weekly maintenance workflows. Scope: TOML configuration, sync commands, idempotent behavior, and backup/restore patterns.

**Detailed Reference**: See `~/.claude/docs/claude-code.md` for comprehensive implementation guide, examples, and troubleshooting.

## Configuration

- Config file: `~/.claude/config/claude-marketplace.toml` defines marketplaces, plugins, and options.
- TOML structure: `[marketplaces]` with enabled list; `[plugins.<marketplace>]` with install arrays and auto_update flags; `[options]` for backup settings.
- Requires yq (or jq) for TOML parsing; validate with `yq eval ~/.claude/config/claude-marketplace.toml`.

## Core commands

- `sh ~/.claude/bin/claude-marketplace-sync.sh sync` (or `mise run update:claude-marketplace`): update marketplace + install plugins from config.
- `update`: pull marketplace repos only. `install`: install plugins only. `status`: show installed plugins. `list`: list available marketplaces.
- All commands are idempotent; duplicate calls are safe. Errors trigger automatic rollback from timestamped backups.

## Backup and restore

- Backup location: `~/.local/state/claude-plugins-backup/TIMESTAMP/plugins/` before every update/install.
- Auto-restore on errors; manual restore: `rm -rf ~/.claude/plugins && cp -R ~/.local/state/claude-plugins-backup/<TIMESTAMP>/plugins ~/.claude/`.

## Weekly maintenance

- Managed in `~/.claude/mise.toml` as `update:claude-marketplace` task.
- Run via `cd ~/.claude && mise run update:claude-marketplace` for standalone execution.
- Keeps all Claude marketplace plugins synchronized with declared config; no manual intervention needed.
- Independent lifecycle from dotfiles updates for better separation of concerns.
