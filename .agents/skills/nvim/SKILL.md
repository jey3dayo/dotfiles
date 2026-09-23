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

For generic Neovim/LSP/lazy.nvim documentation, query Context7 MCP when available; fall back to official Neovim docs otherwise:

- `/websites/neovim_io_doc` — official docs, API reference
- `/folke/lazy.nvim` — plugin manager usage
- `/neovim/neovim` — source code internals

This skill owns the review workflow and criteria below.

For this dotfiles repo, read `docs/tools/nvim.md` for the actual structure, keybindings, and startup times. For other repos, use the repository's own docs/rules first, then Context7 or official Neovim docs.

## Review Workflow

1. Measure: `nvim --startuptime startup.log`, `:Lazy profile`
2. Structure: `init.lua` → `lua/config/` → `lua/plugins/`, plus any `core/` / `lsp/` layers (see the tree below)
3. Plugins: count, `lazy-lock.json` tracked in git, event/cmd/ft triggers on specs
4. LSP: server list, mason `ensure_installed` coverage, and how servers are activated (`vim.lsp.config` / `vim.lsp.enable` with `after/lsp/<server>.lua`, or `lspconfig.<server>.setup`)
5. Keybindings: confirm the actual leader key in the repo's own config, no conflicts
6. AI: `lua/plugins/ai.lua` or `completion.lua`, <50ms latency (verify with profiling)
7. Performance: compare against the benchmarks below
8. Health: `:checkhealth` for providers/LSP
9. Standards: Lua-only, lazy.nvim, LSP-native, AI integration
10. Micro-level polish: Treesitter query tuning, custom-command documentation, explicit plugin dependencies — flag these only after the structural checks above are clean

## Performance Benchmarks

- Startup time: <200ms
- First edit: <300ms from nvim command
- LSP attach: <500ms for most languages
- Plugin load: 90%+ lazy-loaded
- Disable unused providers: `vim.g.loaded_python3_provider = 0`
- Large file detection (>2MB) via a dedicated helper module, consumed by the filetype/lazy-load layer

## Evaluation Focus

Judge against the benchmarks above and report the gap, not a score:

- Startup: lazy-loading ratio, trigger precision (event/cmd/ft), unused providers disabled
- LSP: install coverage for the languages actually used, one activation path (no double setup)
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

Naming varies by repo — verify the actual layout before flagging a deviation.

### Cross-Tool Integration

Check consistency with WezTerm (theme, Nerd Font), Zsh (shared FZF keybindings, env vars), and Git (editor integration).

## Common Issues & Quick Fixes

| Issue                 | Fix                                                                                      |
| --------------------- | ---------------------------------------------------------------------------------------- |
| Startup >500ms        | Check unused providers, lazy loading specs, large file detection                         |
| Legacy plugin manager | Migrate to lazy.nvim, track `lazy-lock.json`                                             |
| Missing LSP server    | Add it to the server list that feeds mason `ensure_installed` and to the activation path |
| Missing lazy loading  | Add event/cmd/ft triggers (`VeryLazy`, `BufReadPre`, `CmdlineEnter`) to plugin specs     |
| Provider errors       | Disable in init.lua: `vim.g.loaded_python3_provider = 0`                                 |

## Related Skills

- `code-review` — overall quality assessment framework
