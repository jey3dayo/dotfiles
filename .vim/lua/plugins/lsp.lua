-- LSP configuration with optimized loading order and dependencies
return {
  -- Core LSP infrastructure - must load first
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 1000, -- High priority for core LSP
    config = function()
      -- Initialize LSP core components first
      require "lsp.quiet"        -- Setup quiet mode before any LSP activity
      require "lsp.client_tracker" -- Initialize client tracking
      require "lsp.performance"  -- Initialize performance monitoring
      require "lsp.handlers"     -- Setup LSP handlers (including client/registerCapability)
      require "config/native-lsp-ui" -- Configure UI handlers
      require "lsp.debug"        -- Debug commands
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
  
  -- EFM language configs - needed before mason-lspconfig
  {
    "creativenull/efmls-configs-nvim",
    lazy = false,
    priority = 800,
    dependencies = { "neovim/nvim-lspconfig" },
  },
  
  -- LSP server auto-configuration - must be last
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    priority = 700, -- Lower priority to ensure dependencies are ready
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig", 
      "creativenull/efmls-configs-nvim", -- Explicit EFM dependency
    },
    config = function()
      require "config/mason-lspconfig"
    end,
  },
}
