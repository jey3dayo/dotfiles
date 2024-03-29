return {
  "ray-x/lsp_signature.nvim",
  {
    "stevearc/conform.nvim",
    config = function()
      require "config/conform"
    end,
  },
  "williamboman/mason.nvim",
  "neovim/nvim-lspconfig",
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require "config/mason"
    end,
  },
  {
    "MunifTanjim/prettier.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    -- cmd = { "Prettier" },
    config = function()
      require "config/prettier"
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require "config/lspsaga"
    end,
  },
}
