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
    -- FIXME: "nvimdev/lspsaga.nvim",
    "nvimdev/lspsaga.nvim",
    commit = "e646183662b7e9b1f3b9d9616116a6a8167e57ff",
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
