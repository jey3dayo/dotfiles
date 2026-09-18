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
      require "lsp.ui" -- Configure UI handlers
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
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- Modern formatting and linting
  {
    "stevearc/conform.nvim",
    lazy = false,
    priority = 800,
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require "setup.conform"
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
      require "lsp.setup"
    end,
  },
}
