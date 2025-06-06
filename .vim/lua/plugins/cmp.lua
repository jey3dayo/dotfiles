local deps = require "utils/dependencies"

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require "config/cmp"
    end,
  },
  { "hrsh7th/cmp-nvim-lsp", dependencies = deps.cmp },
  { "hrsh7th/cmp-nvim-lsp-signature-help", dependencies = deps.cmp },
  { "hrsh7th/cmp-buffer", dependencies = deps.cmp },
  { "hrsh7th/cmp-path", dependencies = deps.cmp },
  { "hrsh7th/cmp-cmdline", dependencies = deps.cmp },
  { "f3fora/cmp-spell", dependencies = deps.cmp },
  { "petertriho/cmp-git", dependencies = deps.cmp },
  { "dcampos/cmp-snippy", dependencies = deps.cmp },
  { "ray-x/cmp-treesitter", dependencies = deps.cmp },
  { "onsails/lspkind-nvim", lazy = true },
  { "roobert/tailwindcss-colorizer-cmp.nvim", lazy = true },
  { "dcampos/nvim-snippy", cmd = { "SnippyEdit", "SnippyReload" }, config = true },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = true,
  },
}
