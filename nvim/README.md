# Neovim Configuration

Comma-leader, Lazy.nvim-based setup. The stack is built around blink.cmp for completion, Conform for manual formatting, and a mostly mini.nvim editing surface. Startup timing is tracked in [docs/tools/nvim.md](../docs/tools/nvim.md#検証).

## Quick Facts

- Plugin manager: lazy.nvim (`lua/init_lazy.lua`), specs grouped under `lua/plugins/`
- Completion: `blink.cmp` + `friendly-snippets`
- Formatting: manual-only via Conform + LSP fallback (no format-on-save; lefthook's pre-commit covers save-time formatting) — JS/TS uses `eslint_d` → `prettier` (+ `biome` when config exists); Stylua, Ruff, gofmt/goimports, rustfmt, shfmt, taplo, prettier for Markdown/YAML
- Treesitter stack: `nvim-treesitter`, `ts-context-commentstring`, `vim-matchup`, `rainbow-delimiters`
- File/search: `mini.pick` + `mini.extra`, `mini.files` as the default explorer, `flash.nvim`/`mini.jump`/`mini.jump2d` for motion
- Leader key: `,` (comma)

## Layout

```
nvim/
├── init.lua
├── lua/
│   ├── init_lazy.lua          # lazy.nvim bootstrap + defaults
│   ├── plugins/               # Plugin specs by category (core/editor/git/lsp/ui/...)
│   ├── config/                # Plugin settings (conform, blink, treesitter, etc.)
│   ├── lsp/                   # LSP wiring, formatter selector, helpers
│   ├── core/                  # Bootstrap utilities, dependencies, filetypes
│   └── ...                    # Misc helpers (neovide, colorscheme)
├── after/lsp/                  # Per-server LSP overrides (wins over nvim-lspconfig's own lsp/*.lua via runtimepath order)
└── snippets/                  # VSCode-style snippets
```

## Plugin Stack (condensed)

- Core/UI: lazy.nvim, noice.nvim + nvim-notify, lualine.nvim, mini.cursorword, mini.icons + nvim-web-devicons, tokyonight.nvim, kanagawa.nvim
- Editing & Motion: mini.ai/surround/pairs/comment/indentscope/trailspace/hipatterns/align/animate/operators/splitjoin/bracketed/tabline/visits/bufremove, mini.sessions, mini.files, mini.pick + mini.extra + mini.clue + mini.fuzzy, mini.misc zoom, mini.ts-autotag, flash.nvim, dial.nvim, im-select.nvim
- Search & Navigation: mini.pick built-ins (files/buffers/grep/diagnostics/symbols/registers), mini.files as default explorer with split helpers
- Completion: blink.cmp + friendly-snippets
- LSP/Formatting: nvim-lspconfig, mason.nvim + mason-lspconfig, conform.nvim, native LSP UI tweaks, fidget.nvim
- Syntax: nvim-treesitter, ts-context-commentstring, vim-matchup, rainbow-delimiters
- Git: vim-fugitive (+ vim-rhubarb + gitlinker), diffview.nvim, neogit, gitsigns.nvim
- Language extras: vim-rails, jsgf.vim
- Utilities: trouble.nvim, suda.vim, vim-startuptime

## Language & Formatting Support

- JS/TS/Vue: `ts_ls` + `eslint`; Conform uses `eslint_d` → `prettier` (+ `biome` when `biome.json` is present)
- Python: `pylsp` + `ruff`; formatting through `ruff_format`/`ruff_fix`
- Go: `gopls` with `gofmt` + `goimports`
- Lua: `lua_ls` + `stylua`
- Web/Config: `cssls`, `jsonls`, `taplo` (TOML), `yamlls`, `marksman`, `dockerls`, `terraformls`, `prismals`, `astro`, `typos_lsp`
- Defaults: `shfmt` for shell, `rustfmt` available, prettier for Markdown/YAML/GraphQL/HTML
- No format-on-save; formatting is manual only via `:Format` / `<C-e>f` or `<C-e>b/p/e/s` for specific formatters (gated by `AutoFormatEnable`/`AutoFormatDisable`, ignored when forced)

## Key Bindings (leader = `,`)

- Search & files: `,f` files, `,,` resume picker, `,gr` live grep, `,b` buffers, `,d` diagnostics, `,Fs`/`,FS` document/workspace symbols, `,e` open mini.files, `,E` open mini.files at buffer dir
- LSP nav: `tt` definition, `tj` references, `tk` implementation, `tl` type definition
- Formatting: `<C-e>f` auto-select formatter, `<C-e>b/p/e/s` for Biome/Prettier/ESLint/TypeScript (ts_ls)
- Maintenance: `,sp` Lazy UI, `,sm` MasonUpdate, `,st` TSUpdate all, `,su` Lazy update
- Tabs/windows: `<C-t>c/d/o/n/p` tab actions, `gt/gT` cycle tabs, `<Tab>` cycles windows

## Maintenance

- Update plugins/treesitter/mason: `,sp`, `,st`, `,sm`, `,su`
- Health/profile: `:checkhealth`, `:Lazy profile`, `:StartupTime`
- Formatting/lint bundles: `mise run format`, `mise run lint`; full CI parity: `mise run ci`
