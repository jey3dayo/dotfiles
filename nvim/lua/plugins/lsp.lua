local ft = require "core.filetypes"
local deps = require "core.dependencies"

-- LSP configuration with optimized loading order and dependencies
return {
  -- Core LSP infrastructure - must load first
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 1000, -- High priority for core LSP
    config = function()
      -- Initialize LSP core components first
      require "lsp.quiet" -- Setup quiet mode before any LSP activity
      -- Client tracking is now handled by simplified client_utils.lua
      -- Performance monitoring removed - use :LspInfo and built-in tools
      require "lsp.handlers" -- Setup LSP handlers (including client/registerCapability)
      require "config/native-lsp-ui" -- Configure UI handlers
      require "lsp.debug" -- Debug commands
    end,
  },

  -- Package manager - depends on lspconfig
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 900,
    dependencies = { "neovim/nvim-lspconfig" },
    opts = require "config/mason",
  },

  -- Modern formatting and linting
  {
    "stevearc/conform.nvim",
    lazy = false,
    priority = 800,
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require "config/conform"
    end,
  },

  {
    "mfussenegger/nvim-lint",
    lazy = false,
    priority = 799,
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require "config/nvim-lint"
    end,
  },

  -- Enhanced TypeScript experience (tsserver wrapper)
  {
    "pmizio/typescript-tools.nvim",
    ft = ft.js_project,
    dependencies = {
      deps.plenary,
      deps.lspconfig,
    },
    opts = function()
      return require "lsp.settings.typescript-tools"
    end,
    config = function(_, opts)
      require("typescript-tools").setup(opts)
    end,
  },

  -- LSP server auto-configuration - must be last
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    priority = 700, -- Lower priority to ensure dependencies are ready
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require "config/mason-lspconfig"
    end,
  },
}
