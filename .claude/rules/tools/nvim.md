---
paths: nvim/**/*, docs/tools/nvim.md
source: docs/tools/nvim.md
---

# Neovim Rules

Purpose: keep the Lua-first Neovim configuration stable; startup targets and measured baselines live in `docs/tools/nvim.md`. Scope: architecture, LSP/tooling, performance safeguards.

Detailed Reference: See [docs/tools/nvim.md](../../../docs/tools/nvim.md) for comprehensive implementation guide, examples, and troubleshooting.

## Architecture

- Fully Lua; structure is init.lua -> lua/config (plugin settings) -> lua/plugins (lazy.nvim-style specs) and lua/pack (custom loader), with lua/core and lua/lsp for shared foundations.
- Plugins are managed by built-in `vim.pack` (lockfile `nvim/nvim-pack-lock.json`, tracked in git); lazy loading is done by the custom loader in `lua/pack/`, which implements event/cmd/keys/ft/VeryLazy. Prefer event/condition-based loading.
- Unsupported lazy spec keys raise an error; specs that use `opts` or `config = true` need an explicit `main`.
- `NVIM_PACK_BOOTSTRAP=1` makes a headless first install non-interactive and skips the `:TSUpdate` build hook. The last lazy.nvim state is tagged `nvim-lazy-last`.
- Separate core vs UI vs LSP vs AI layers when adding plugins.

## LSP and tooling

- Server list lives in `lua/lsp/config.lua` (`M.servers`); mason-lspconfig installs it (`automatic_enable = false`) and `lua/lsp/setup.lua` activates it via `vim.lsp.config` / `vim.lsp.enable`.
- Per-server settings go in `after/lsp/<server>.lua`; add new servers through Mason rather than external managers.
- Retain gitsigns, mini.pick, and mini.files for workflows unless performance regression is proven.

## Performance guards

- Meet Neovim startup targets in `docs/tools/nvim.md` (measure with `nvim --startuptime`; record changes there, not in this rule).
- Disable Treesitter for files >2MB; keep python/ruby providers disabled unless required.
- For regressions, clear ~/.local/share/nvim and ~/.local/state/nvim before reinstalling.

## Customization rules

- Add new settings under lua/config or plugin definitions under lua/plugins. Machine-specific override files are not used; project-specific overrides go through `load_config.lua`, which searches upward from cwd for `nvim.config.lua` (see `docs/tools/nvim.md`).
- Document major plugin additions with their load conditions to preserve lazy-loading behavior.
