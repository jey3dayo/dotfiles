return {
  "ray-x/lsp_signature.nvim",
  {
    "williamboman/mason.nvim",
    opts = require "config/mason",
  },
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require "config/mason-lspconfig"
    end,
  },
  {
    "nvimdev/lspsaga.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = require "config/lspsaga",
  },
  {
    "creativenull/efmls-configs-nvim",
    dependencies = { "neovim/nvim-lspconfig" },
  },
}
