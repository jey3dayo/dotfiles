return {
  { "williamboman/mason.nvim", cmd = "Mason", opts = require "config/mason" },
  { "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" } },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim" },
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
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "neovim/nvim-lspconfig" },
  },
}
