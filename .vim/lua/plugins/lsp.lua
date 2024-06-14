return {
  "ray-x/lsp_signature.nvim",
  {
    "stevearc/conform.nvim",
    config = function()
      require "config/conform"
    end,
  },
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
}
