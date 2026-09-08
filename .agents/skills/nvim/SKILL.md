---
name: nvim
description: >-
  Review and improve Neovim configurations: startup performance, lazy.nvim
  plugin management and lazy loading, LSP setup (mason), modern Lua config
  structure, and AI completion integration. Use when the user mentions Neovim
  or nvim, edits init.lua or lua/ Neovim config files, or asks about editor
  startup time, LSP configuration, or plugin management.
---

# Neovim Configuration Review

Reviews Neovim configurations focusing on startup performance, LSP integration, plugin management, and modern Lua patterns.

For generic Neovim/LSP/lazy.nvim documentation, query Context7 MCP when available; fall back to official Neovim docs plus `references/nvim.md` otherwise:

- `/websites/neovim_io_doc` — official docs, API reference
- `/folke/lazy.nvim` — plugin manager usage
- `/neovim/neovim` — source code internals

This skill owns the dotfiles-specific patterns and review criteria below.

## Review Workflow

1. Measure: `nvim --startuptime startup.log`, `:Lazy profile`
2. Structure: `init.lua` → `lua/config/` → `lua/plugins/`, plus any `core/` / `lsp/` layers (see the tree below)
3. Plugins: count, `lazy-lock.json` tracked in git, event/cmd/ft triggers on specs
4. LSP: mason setup, `ensure_installed` coverage, pcall wrapping — the wiring lives in `lua/plugins/lsp.lua` or a dedicated `lua/lsp/` module depending on the repo
5. Keybindings: confirm the actual leader key in the repo's own config (this dotfiles repo uses comma, `,`, not Space — check `keymaps.lua` or equivalent before assuming), no conflicts
6. AI: `lua/plugins/ai.lua` or `completion.lua`, <50ms latency (verify with profiling)
7. Performance: compare against benchmarks below and `references/nvim.md`
8. Health: `:checkhealth` for providers/LSP
9. Standards: Lua-only, lazy.nvim, LSP-native, AI integration

If the current repository has tool-specific rules or docs, compare against them first. Otherwise use `references/nvim.md` as the local baseline.

## Performance Benchmarks

- Startup time: <200ms (ideal <100ms)
- First edit: <300ms from nvim command
- LSP attach: <500ms for most languages
- Plugin load: 90%+ lazy-loaded
- Disable unused providers: `vim.g.loaded_python3_provider = 0`
- Large file detection (>2MB) in `config/autocmds.lua`

## Evaluation Focus

Judge against the benchmarks above and report the gap, not a score:

- Startup: lazy-loading ratio, trigger precision (event/cmd/ft), unused providers disabled
- LSP: mason auto-install coverage for the languages actually used, pcall-wrapped setup
- Plugins: lazy.nvim with `lazy-lock.json` tracked; flag legacy managers (packer, vim-plug) and Vimscript-heavy config
- Practices: Lua-only config, AI completion integrated without measurable latency

## Expected File Organization

```
nvim/
├── init.lua                    # Entry point (often delegates to a bootstrap module)
├── lazy-lock.json              # Plugin versions (tracked in git)
└── lua/
    ├── config/                 # Per-plugin settings
    ├── plugins/                # Modular lazy.nvim specs: editor, lsp, ui, git, ai
    ├── core/                   # Bootstrap/startup, dependency, filetype helpers (if present)
    └── lsp/                    # LSP wiring, formatter/linter helpers (if present)
```

Naming varies by repo — verify the actual layout (e.g. this dotfiles repo uses `lua/core/bootstrap.lua` as the entry delegate and has no `local.lua`/`utils/` directories) before flagging a deviation.

### Cross-Tool Integration

Check consistency with WezTerm (theme, Nerd Font), Zsh (shared FZF keybindings, env vars), and Git (editor integration).

## Common Issues & Quick Fixes

| Issue                 | Fix                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------ |
| Startup >500ms        | Check unused providers, lazy loading specs, large file detection                           |
| Legacy plugin manager | Migrate to lazy.nvim, track `lazy-lock.json`                                               |
| <10 LSP languages     | Configure `ensure_installed` in `lua/plugins/lsp.lua` with `automatic_installation = true` |
| Missing lazy loading  | Add event/cmd/ft triggers (`VeryLazy`, `BufReadPre`, `CmdlineEnter`) to plugin specs       |
| Provider errors       | Disable in init.lua: `vim.g.loaded_python3_provider = 0`                                   |

## Related Skills

- `code-review` — overall quality assessment framework

## References

- `references/nvim.md` — skill-local baseline, benchmarks, and maintenance notes
