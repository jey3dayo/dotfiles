# Neovim Configuration

Modern Lua-based Neovim configuration with <100ms startup time and comprehensive LSP support for 15+ languages.

## ✨ Key Features

- **🚀 Performance**: <100ms startup with lazy.nvim optimization
- **🔧 LSP Support**: 15+ programming languages with full IDE features
- **🤖 AI Integration**: GitHub Copilot + Avante.nvim for AI assistance
- **📦 Plugin Management**: lazy.nvim for efficient plugin loading
- **🎨 Modern UI**: Telescope, nvim-tree, and enhanced visual experience
- **⚡ Fast Navigation**: Harpoon, leap.nvim, and optimized workflows

## 📈 Performance Metrics

| Component          | Startup Time | Optimization      |
| ------------------ | ------------ | ----------------- |
| Total startup      | <100ms       | lazy.nvim         |
| Plugin loading     | Deferred     | Conditional       |
| LSP initialization | On-demand    | Language-specific |
| File navigation    | Instant      | Cached indexing   |

## 🏗️ Architecture

### Modular Structure

```
nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config/           # Core configuration
│   │   ├── options.lua   # Vim options
│   │   ├── keymaps.lua   # Key mappings
│   │   ├── autocmds.lua  # Auto commands
│   │   └── lazy.lua      # Plugin manager setup
│   ├── plugins/          # Plugin configurations
│   │   ├── lsp/          # LSP configurations
│   │   ├── ui/           # UI enhancements
│   │   ├── editor/       # Editor functionality
│   │   └── tools/        # Development tools
│   └── utils/            # Utility functions
└── after/
    └── ftplugin/         # Filetype-specific settings
```

### Plugin Categories

- **Core**: Essential functionality and performance
- **LSP**: Language server configurations
- **UI**: Interface enhancements and theming
- **Editor**: Text editing and navigation
- **Tools**: Development and debugging tools
- **AI**: Copilot and AI assistance

## 🛠️ Supported Languages & LSP

### Programming Languages (15+)

```
├── Lua          # lua_ls + stylua formatting
├── TypeScript   # tsserver + prettier + eslint
├── JavaScript   # tsserver + prettier + eslint
├── Python       # pyright + black + ruff
├── Rust         # rust_analyzer + rustfmt
├── Go           # gopls + goimports + gofmt
├── C/C++        # clangd + clang-format
├── Java         # jdtls + google-java-format
├── PHP          # phpactor + php-cs-fixer
├── Ruby         # solargraph + rubocop
├── Swift        # sourcekit-lsp
├── Kotlin       # kotlin_language_server
├── C#           # omnisharp
├── Dart         # dartls
└── Shell        # bashls + shfmt + shellcheck
```

### Markup & Config

```
├── HTML/CSS     # html, cssls + prettier
├── JSON         # jsonls + prettier
├── YAML         # yamlls + prettier
├── TOML         # taplo
├── Markdown     # marksman + markdownlint
└── Docker       # dockerls + hadolint
```

## 🎮 Key Bindings

### Leader Key: `<Space>`

#### File & Navigation

```lua
<leader>ff      -- Find files (Telescope)
<leader>fg      -- Live grep (Telescope)
<leader>fb      -- Find buffers (Telescope)
<leader>fh      -- Help tags (Telescope)
<leader>e       -- Toggle file explorer
<leader><leader> -- Harpoon quick menu
```

#### LSP Features

```lua
gd              -- Go to definition
gr              -- Find references
gi              -- Go to implementation
K               -- Hover documentation
<leader>ca      -- Code actions
<leader>rn      -- Rename symbol
<leader>f       -- Format document
[d / ]d         -- Navigate diagnostics
```

#### AI & Development

```lua
<leader>cc      -- Copilot chat
<leader>av      -- Avante toggle
<leader>gg      -- Lazygit
<leader>tt      -- Terminal toggle
<leader>db      -- Debug toggle breakpoint
```

#### Text Editing

```lua
s<char><char>   -- Leap motion (jump to characters)
<C-h/j/k/l>     -- Window navigation
<leader>w       -- Save file
<leader>q       -- Quit
<leader>/       -- Toggle comment
```

## 🔧 Plugin Ecosystem

### Core Performance

- **lazy.nvim**: Lazy loading plugin manager
- **plenary.nvim**: Lua utility functions
- **which-key.nvim**: Key binding hints

### LSP & Completion

- **nvim-lspconfig**: LSP configurations
- **mason.nvim**: LSP server manager
- **nvim-cmp**: Completion engine
- **cmp-nvim-lsp**: LSP completion source
- **luasnip**: Snippet engine

### UI & Navigation

- **telescope.nvim**: Fuzzy finder
- **nvim-tree.lua**: File explorer
- **harpoon**: Quick file navigation
- **leap.nvim**: Motion plugin
- **lualine.nvim**: Status line

### AI & Development Tools

- **copilot.lua**: GitHub Copilot
- **avante.nvim**: AI chat integration
- **gitsigns.nvim**: Git integration
- **lazygit.nvim**: Git UI
- **nvim-dap**: Debug adapter protocol

### Editor Enhancement

- **nvim-treesitter**: Syntax highlighting
- **indent-blankline.nvim**: Indentation guides
- **comment.nvim**: Smart commenting
- **autopairs**: Auto bracket pairing
- **surround.nvim**: Text object manipulation

## 🎨 Theming & UI

### Color Schemes

- **Primary**: Gruvbox (consistent with other tools)
- **Alternative**: Tokyo Night
- **Fallback**: Built-in colorschemes

### UI Enhancements

```lua
-- Transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

-- Custom highlights for LSP
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ea6962" })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#d8a657" })
```

### Status Line

- **Mode indicator**: Visual mode display
- **Git branch**: Current branch and changes
- **LSP status**: Active language servers
- **Diagnostics**: Error/warning counts
- **File info**: Type, encoding, position

## 🤖 AI Integration

### GitHub Copilot

```lua
-- Setup in plugins/ai/copilot.lua
require('copilot').setup({
  suggestion = { enabled = false },  -- Use cmp instead
  panel = { enabled = false },
})

-- Completion integration
require('copilot_cmp').setup()
```

### Avante.nvim (AI Chat)

```lua
-- Chat with AI about code
<leader>av      -- Toggle Avante window
<leader>ae      -- Edit with AI
<leader>ar      -- Refresh AI response
```

## 🔍 LSP Configuration

### Mason Setup (Automatic)

```lua
-- Auto-install LSP servers
require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'lua_ls', 'tsserver', 'pyright', 'rust_analyzer',
    'gopls', 'clangd', 'jdtls', 'phpactor'
  },
  automatic_installation = true,
})
```

### Custom LSP Settings

```lua
-- Lua LSP with workspace setup
lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = { enable = false },
    },
  },
})
```

## 🚀 Performance Optimization

### Startup Optimization

```lua
-- Disable unused providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Lazy load UI components
vim.defer_fn(function()
  require('nvim-tree').setup()
end, 0)
```

### Memory Management

- **Buffer limits**: Automatic cleanup of unused buffers
- **Swap files**: Disabled for better performance
- **Undo persistence**: Efficient undo history management

### Loading Strategy

1. **Immediate**: Core options and keymaps
2. **VimEnter**: UI components and theme
3. **BufReadPre**: File-type specific plugins
4. **LspAttach**: Language server features

## 📊 Debug & Profiling

### Startup Profiling

```bash
# Measure startup time
nvim --startuptime startup.log

# Profile specific operations
:profile start profile.log
:profile func *
:profile file *
```

### Plugin Analysis

```lua
-- Check plugin load times
:Lazy profile

-- Debug LSP status
:LspInfo
:LspLog

-- Check Treesitter status
:TSInstallInfo
```

## ⚙️ Customization

### Local Configuration

Create `lua/config/local.lua` for machine-specific settings:

```lua
-- Local overrides
vim.opt.background = "light"  -- Override theme
vim.g.copilot_enabled = false -- Disable Copilot

-- Custom keymaps
vim.keymap.set('n', '<leader>ll', ':Lazy<CR>')

-- LSP server customization
local custom_servers = { 'custom_ls' }
```

### Plugin Customization

```lua
-- Override plugin settings
return {
  'nvim-telescope/telescope.nvim',
  opts = {
    defaults = {
      file_ignore_patterns = { "node_modules", ".git" },
      layout_strategy = "horizontal",
    },
  },
}
```

## 🔧 Advanced Features

### Custom Commands

```lua
-- Format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- Auto-compile plugins
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*/nvim/lua/**/*.lua",
  command = "source <afile> | PackerCompile",
})
```

### Development Workflow

```lua
-- Project-specific settings
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    local project_config = vim.fn.getcwd() .. "/.nvim.lua"
    if vim.fn.filereadable(project_config) == 1 then
      dofile(project_config)
    end
  end,
})
```

## 📋 Maintenance

### Regular Tasks

```bash
# Weekly plugin updates
:Lazy update

# Monthly LSP server updates
:MasonUpdate

# Quarterly cleanup
:Lazy clean
```

### Health Checks

```bash
# Comprehensive health check
:checkhealth

# Specific component checks
:checkhealth nvim
:checkhealth lsp
:checkhealth treesitter
```

### Troubleshooting

```bash
# Reset plugin state
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# Debug mode startup
nvim --clean
nvim -u NONE
```

---

_Optimized for modern development with AI assistance and comprehensive language support._
