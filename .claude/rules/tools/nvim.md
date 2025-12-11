---
paths:
  - "nvim/**/*"
  - "docs/tools/nvim.md"
---

# Neovim Rules

Purpose: keep the Lua-first, <100ms Neovim configuration stable. Scope: architecture, LSP/tooling, performance safeguards.
Sources: docs/tools/nvim.md, docs/performance.md.

## Architecture
- Fully Lua; structure is init.lua -> lua/config (core settings) -> lua/plugins (lazy-loaded) -> lua/utils.
- Use lazy.nvim with defaults.lazy=true; prefer event/condition-based loading.
- Separate core vs UI vs LSP vs AI layers when adding plugins.

## LSP and tooling
- Manage tools with mason.nvim + mason-lspconfig; configure servers via lspconfig.
- Keep 15-language support; add new servers through Mason rather than external managers.
- Retain Supermaven (AI) and gitsigns/telescope for workflows unless performance regression is proven.

## Performance guards
- Maintain <100ms startup; measure with `nvim --startuptime` and `:Lazy profile`.
- Disable Treesitter for files >2MB; keep python/ruby providers disabled unless required.
- For regressions, clear ~/.local/share/nvim and ~/.local/state/nvim before reinstalling.

## Customization rules
- Add new settings under lua/config or plugin definitions under lua/plugins; prefer local.lua for machine-specific tweaks.
- Document major plugin additions with their load conditions to preserve lazy behavior.
