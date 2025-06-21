return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = require "config/mason",
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
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
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = require "config/lspsaga",
  },
  {
    "creativenull/efmls-configs-nvim",
    lazy = false,
    dependencies = { "neovim/nvim-lspconfig" },
  },
}
