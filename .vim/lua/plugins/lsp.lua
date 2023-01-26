return {
  "nvim-lua/plenary.nvim",
  "neovim/nvim-lspconfig",
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("config/null-ls")
    end,
  },

  "ray-x/lsp_signature.nvim",
  {
    "glepnir/lspsaga.nvim",
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
  { "MunifTanjim/prettier.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
      require("config/prettier")
    end,
  },
}
