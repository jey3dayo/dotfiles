return {
  "nvim-lua/plenary.nvim",
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("config/nvim-lspconfig")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("config/null-ls")
    end,
  },

  "ray-x/lsp_signature.nvim",
  {
    "glepnir/lspsaga.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("config/lspsaga")
    end,
  },
  "williamboman/mason.nvim",
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("config/mason")
    end,
  },
}
