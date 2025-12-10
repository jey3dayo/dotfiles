---
paths:
  - "wezterm/**"
  - "alacritty/**"
  - "docs/tools/wezterm.md"
---

# Terminal Rules (WezTerm)

Purpose: keep the GPU-accelerated WezTerm setup consistent. Scope: config structure, key bindings, platform handling.
Sources: docs/tools/wezterm.md.

## Config structure
- Files: wezterm.lua (entry), keybinds.lua, ui.lua, events.lua, utils.lua, os.lua, win.lua.
- Keep Gruvbox theme, 92% opacity, tab bar at bottom, and WebGpu front_end by default.

## Key bindings
- Leader is Ctrl+x. Core bindings: Ctrl+x c/n/p for tab create/next/prev; Ctrl+x & to close tab; Ctrl+x | / - for splits; Ctrl+x z for zoom; Ctrl+x x to close pane; Ctrl+x [ enters copy mode with Vim keys.
- Direct binds: Alt+Tab for tab switch; Alt+h/j/k/l to move panes; Alt+Shift+Ctrl+h/j/k/l to resize; Ctrl+plus/minus for font size.

## Platform handling
- Detect platform via utils; on Windows set default_domain to WSL:Ubuntu. Keep GPU acceleration unless debugging.
- Troubleshooting options: `wezterm start --config 'front_end="Software"'` for software rendering, `wezterm check` for config validation.

## Maintenance
- Update via `brew upgrade wezterm`; back up ~/.config/wezterm before major edits. Maintain consistency with other tools (Gruvbox theme and shared key philosophy).
