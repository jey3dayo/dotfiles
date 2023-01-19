return {
  { "hrsh7th/nvim-cmp",
    config = function()
      require("config/cmp")
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = { "tpope/vim-fugitive" }
  },
  {
    "hrsh7th/cmp-buffer",
    dependencies = { "tpope/vim-fugitive" }
  },
  {
    "hrsh7th/cmp-vsnip",
    dependencies = { "tpope/vim-fugitive" }
  },
  "onsails/lspkind-nvim",
}
