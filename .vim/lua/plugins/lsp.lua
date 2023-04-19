return {
  "neovim/nvim-lspconfig",
  "ray-x/lsp_signature.nvim",
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require "config/null-ls"
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    config = function()
      require "config/lspsaga"
    end,
  },
  "williamboman/mason.nvim",

  {
    "jayp0521/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
      require "config/mason"
    end,
  },
  {
    "MunifTanjim/prettier.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = function()
      require "config/prettier"
    end,
  },
}
