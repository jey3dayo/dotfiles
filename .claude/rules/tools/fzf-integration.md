---
paths:
  - "docs/tools/fzf-integration.md"
  - "zsh/config/tools/fzf.zsh"
  - "zsh/sources/styles.zsh"
  - "zsh/**/*fzf*.zsh"
---

# FZF Integration Rules

Purpose: centralize FZF bindings and cross-tool integrations. Scope: keymaps, layer coverage, and config locations.
Sources: docs/tools/fzf-integration.md.

## Scope and SST
- This file is the single source for FZF bindings; other docs should link here instead of repeating keymaps.
- Integration spans shell (history, processes, directories), Git (repositories, branches, worktrees, files, stash), Tmux, and Neovim.

## Key bindings
- Global: Ctrl+] ghq repo picker; Ctrl+R history; Ctrl+T file picker; Ctrl+g? show fzf-git maps; Ctrl+g^K process kill.
- Git-focused: Ctrl+g^b/Ctrl+gs branch switch with worktree cd; Ctrl+g^w/Ctrl+gw manage worktrees; Ctrl+g^f diff/file pickers; Ctrl+g^s status; Ctrl+g^a add -p; Ctrl+g^g diff widget; wtcd <branch> jumps to worktree.
- Tmux: prefix+s for session picker; prefix+w for window picker.

## Configuration notes
- Core options set in ~/.config/zsh/config/tools/fzf.zsh; keep FZF_DEFAULT_OPTS height 50% and reverse layout with preview toggles and Gruvbox colors.
- fzf-tab lives in zsh/sources/styles.zsh; retain colorized completions and formatting styles.
- Ensure plugins in sheldon/plugins.toml use defer where needed (fzf-tab at defer tier 2, fzf-git with apply source) to avoid startup regressions.
