---
paths: docs/tools/fzf-integration.md, zsh/lib/git-widgets.zsh, zsh/**/*fzf*.zsh
source: docs/tools/fzf-integration.md
---

# FZF Integration Rules

Purpose: centralize FZF bindings and cross-tool integrations. Scope: keymaps, layer coverage, and config locations.

Detailed Reference: See [docs/tools/fzf-integration.md](../../../docs/tools/fzf-integration.md) for comprehensive implementation guide, examples, and troubleshooting.

## Scope and SST

- `docs/tools/fzf-integration.md` is the single source for FZF bindings; this rule is a compact mirror. Other docs link there instead of repeating keymaps.
- Integration spans shell (history via atuin, processes, directories) and Git (repositories, branches, worktrees, files, stash). Tmux and Neovim are not currently FZF-integrated (see docs "未確認・対象外の統合").

## Key bindings

- Global: Ctrl+] ghq repo picker (FZF); Ctrl+R history (atuin, not FZF); Ctrl+T file picker (FZF); Ctrl+g? show fzf-git maps; Ctrl+gx/Ctrl+g^x process kill (FZF).
- Git-focused: Ctrl+gg/Ctrl+g^g action menu (FZF); Ctrl+gs/Ctrl+g^s status (buffer insert, no FZF); Ctrl+ga/Ctrl+g^a add -p (buffer insert, no FZF); Ctrl+gb/Ctrl+g^b `gh browse` (no FZF); Ctrl+gB branch switch with worktree cd (FZF; no Ctrl variant); Ctrl+gW/Ctrl+g^W worktree manager menu (FZF); Ctrl+gw/Ctrl+g^w worktree list insert via fzf-git (no auto-cd, ctrl-x removes); Ctrl+gz/Ctrl+g^z stash picker (fzf-git, ctrl-x drops); Ctrl+g^f fzf-git file/diff picker.
- Note: All Ctrl+g commands support both patterns (Ctrl+gX or Ctrl+g^X).
- `gco` is a static zsh-abbr abbreviation for `git checkout` (not FZF). `wtcd` does not exist in this repo.

## Configuration notes

- Core FZF options (`FZF_DEFAULT_OPTS`, `FZF_CTRL_T_*`) are set in `zsh/lib/fzf.zsh`; no Gruvbox `--color` theming and no `FZF_CTRL_R_OPTS` are configured there today.
- fzf-tab zstyle config lives in `zsh/lib/fzf-tab.zsh`.
- `sheldon/plugins.toml` registers both `fzf-tab` and `fzf-git` with `apply = ["noop"]` (no `defer`); actual lazy loading happens via `add-zsh-hook precmd` in `zsh/lib/fzf-tab.zsh` and `zsh/lib/git-widgets.zsh`.
