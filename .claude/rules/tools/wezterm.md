---
paths: wezterm/**/*, alacritty/**/*, docs/tools/wezterm.md
source: docs/tools/wezterm.md
---

# WezTerm Rules

Purpose: keep the GPU-accelerated WezTerm setup consistent. Scope: config structure, key bindings, platform handling.

Detailed Reference: See [docs/tools/wezterm.md](../../../docs/tools/wezterm.md) for comprehensive implementation guide, examples, and troubleshooting.

## Config structure

- Files: wezterm.lua (entry), config.lua (base settings), constants.lua, keybinds.lua, key_tables.lua, ui.lua, events.lua, utils.lua, os.lua, win.lua.
- Defaults: Gruvbox theme, 92% opacity (`constants.DEFAULT_OPACITY`), tab bar at bottom, `front_end = "OpenGL"` with `max_fps = 60` in config.lua.

## Key bindings

- Leader is Ctrl+x. Core bindings: Ctrl+x c/n/p for tab create/next/prev; Ctrl+x & to close tab; Ctrl+x | / - for splits; Ctrl+x z for zoom; Ctrl+x x to close pane; Ctrl+x [ enters copy mode with Vim keys.
- Direct binds: Alt+Tab for tab switch; Alt+h/j/k/l to move panes; Alt+Shift+Ctrl+h/j/k/l to resize; Ctrl+plus/minus for font size.

## Platform handling

- Detect platform via utils; on Windows set default_domain to WSL:Ubuntu. Keep GPU acceleration unless debugging.
- Troubleshooting options: `wezterm start --config 'front_end="Software"'` for software rendering, `wezterm check` for config validation.

## Maintenance

- Update via `brew upgrade wezterm`; back up ~/.config/wezterm before major edits. Theme is not unified across tools (Neovim uses 0x96f); keep the shared key philosophy.
