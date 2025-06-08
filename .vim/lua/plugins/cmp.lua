local deps = require("core.dependencies")

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = function()
      require("config/cmp")
    end,
  },
  { "hrsh7th/cmp-nvim-lsp", event = "InsertEnter", dependencies = deps.cmp },
  { "hrsh7th/cmp-nvim-lsp-signature-help", event = "InsertEnter", dependencies = deps.cmp },
  { "hrsh7th/cmp-buffer", event = "InsertEnter", dependencies = deps.cmp },
  { "hrsh7th/cmp-path", event = "InsertEnter", dependencies = deps.cmp },
  { "hrsh7th/cmp-cmdline", event = "CmdlineEnter", dependencies = deps.cmp },
  { "f3fora/cmp-spell", event = "InsertEnter", dependencies = deps.cmp },
  { "petertriho/cmp-git", ft = { "gitcommit", "markdown" }, dependencies = deps.cmp },
  { "dcampos/cmp-snippy", event = "InsertEnter", dependencies = deps.cmp },
  { "ray-x/cmp-treesitter", event = "InsertEnter", dependencies = deps.cmp },
  { "onsails/lspkind-nvim", lazy = true },
  { "roobert/tailwindcss-colorizer-cmp.nvim", lazy = true },
  { "dcampos/nvim-snippy", cmd = { "SnippyEdit", "SnippyReload" }, config = true },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = true,
  },
}
