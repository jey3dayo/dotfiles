---
name: nvim
description: >-
  Review and improve Neovim configurations: startup performance, lazy.nvim
  plugin management and lazy loading, LSP setup (mason), modern Lua config
  structure, and AI completion integration. Use when the user mentions Neovim
  or nvim, edits init.lua or lua/ Neovim config files, or asks about editor
  startup time, LSP configuration, or plugin management. Also trigger on the
  editor tool ecosystem even when "nvim" is not said: mason, marksman, biome,
  conform, none-ls, treesitter, LSP server availability, or formatter/linter
  choice for the editor (e.g. `marksman使える？`, `formatterどれがいい？`).
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
2. Structure: `init.lua` → `lua/config/` → `lua/plugins/`
3. Plugins: count, `lazy-lock.json` tracked in git, event/cmd/ft triggers on specs
4. LSP: `lua/plugins/lsp.lua` mason setup, `ensure_installed` coverage, pcall wrapping
5. Keybindings: space leader, no conflicts
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

## 5-Star Evaluation Criteria

### Startup Performance

| Rating | Time     | Lazy Loading | Plugin Specs     | Unused Features |
| ------ | -------- | ------------ | ---------------- | --------------- |
| 5/5    | <100ms   | 90%+ plugins | Precise triggers | Disabled        |
| 4/5    | <200ms   | 70%+ plugins | Optimized        | Minimal         |
| 3/5    | <500ms   | 50%+ plugins | Basic            | Some            |
| 2/5    | 500ms-1s | <50% plugins | Legacy manager   | Many            |
| 1/5    | >1s      | None         | Vimscript        | No optimization |

### LSP Integration

- 5: 15+ languages, mason auto-install, pcall wrapping, full features
- 4: 10-14 languages, mason integration, basic error handling
- 3: 5-9 languages, manual setup, partial features
- 2: <5 languages, manual installation, basic setup
- 1: No LSP or broken configuration

### Plugin Ecosystem

- 5: lazy.nvim, 90%+ event/cmd/ft triggers, lock file tracked
- 4: lazy.nvim, 70%+ lazy-loaded, documented
- 3: packer, 50%+ lazy-loaded, some docs
- 2: vim-plug, minimal lazy loading, no docs
- 1: Legacy manager, no lazy loading

### Modern Practices

- 5: Complete Lua, lazy.nvim, mason LSP, AI integration
- 4: Complete Lua, lazy.nvim, mason LSP
- 3: Mostly Lua, modern plugin manager
- 2: Mixed Lua/Vimscript, legacy manager
- 1: Vimscript-based configuration

## Expected File Organization

```
nvim/
├── init.lua                    # Entry point
├── lazy-lock.json              # Plugin versions (tracked in git)
├── lua/
│   ├── config/                 # lazy.nvim bootstrap, options, keymaps, autocmds
│   ├── plugins/                # Modular specs: editor, lsp, ui, git, ai
│   └── utils/                  # Utility functions
└── local.lua                   # Machine-specific overrides (gitignored)
```

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
