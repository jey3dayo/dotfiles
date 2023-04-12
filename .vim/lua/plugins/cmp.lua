return {
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require "config/cmp"
    end,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = { "hrsh7th/nvim-cmp" },
  },
  {
    "hrsh7th/cmp-buffer",
    dependencies = { "hrsh7th/nvim-cmp" },
  },
  {
    "hrsh7th/cmp-path",
    dependencies = { "hrsh7th/nvim-cmp" },
  },
  {
    "hrsh7th/cmp-cmdline",
    dependencies = { "hrsh7th/nvim-cmp" },
  },
  {
    "petertriho/cmp-git",
    dependencies = { "hrsh7th/nvim-cmp" },
  },
  {
    "dcampos/cmp-snippy",
    dependencies = { "hrsh7th/nvim-cmp" },
  },
  "onsails/lspkind-nvim",
}
