return {
  "nvim-lua/plenary.nvim",
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.cmd([[ source ~/.config/nvim/plugins/nvim-lsp.rc.vim ]])
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
    commit = "db0c1414efb928a9387e0a3271d75dcc3370822f",
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
