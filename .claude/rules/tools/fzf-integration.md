---
paths: docs/tools/fzf-integration.md, zsh/lib/git-widgets.zsh, zsh/**/*fzf*.zsh
source: docs/tools/fzf-integration.md
---

# FZF Integration Rules

Purpose: centralize FZF bindings and cross-tool integrations. Scope: keymaps, layer coverage, and config locations.

Detailed Reference: See [docs/tools/fzf-integration.md](../../../docs/tools/fzf-integration.md) for comprehensive implementation guide, examples, and troubleshooting.

## Scope and SST

- The Key Bindings table in `docs/tools/fzf-integration.md` is the sole binding list; do not re-enumerate keymaps in this rule or other docs.
- Integration spans shell (history via atuin, processes, directories) and Git (repositories, branches, worktrees, files, stash). Tmux and Neovim are not currently FZF-integrated (see docs "未確認・対象外の統合").

## Configuration notes

- Core FZF options (`FZF_DEFAULT_OPTS`, `FZF_CTRL_T_*`) are set in `zsh/lib/fzf.zsh`; no Gruvbox `--color` theming and no `FZF_CTRL_R_OPTS` are configured there today.
- fzf-tab zstyle config lives in `zsh/lib/fzf-tab.zsh`.
- `sheldon/plugins.toml` registers both `fzf-tab` and `fzf-git` with `apply = ["noop"]` (no `defer`); actual lazy loading happens via `add-zsh-hook precmd` in `zsh/lib/fzf-tab.zsh` and `zsh/lib/git-widgets.zsh`.
