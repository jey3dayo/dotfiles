local dependencies = { "hrsh7th/nvim-cmp" }

return {
  {
    "hrsh7th/nvim-cmp",
    config = function()
      require "config/cmp"
    end,
  },
  { "hrsh7th/cmp-nvim-lsp", dependencies },
  { "hrsh7th/cmp-nvim-lsp-signature-help", dependencies },
  { "hrsh7th/cmp-buffer", dependencies },
  { "hrsh7th/cmp-path", dependencies },
  { "hrsh7th/cmp-cmdline", dependencies },
  { "f3fora/cmp-spell", dependencies },
  { "petertriho/cmp-git", dependencies },
  { "dcampos/cmp-snippy", dependencies },
  { "ray-x/cmp-treesitter", dependencies },
  "onsails/lspkind-nvim",
  "roobert/tailwindcss-colorizer-cmp.nvim",
  { "dcampos/nvim-snippy", cmd = { "SnippyEdit", "SnippyReload" }, config = true },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = true,
  },
}
