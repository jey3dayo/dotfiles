return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = require "config/mason",
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "config/native-lsp-ui"
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require "config/mason-lspconfig"
    end,
  },
  {
    "creativenull/efmls-configs-nvim",
    lazy = false,
    dependencies = { "neovim/nvim-lspconfig" },
  },
}
