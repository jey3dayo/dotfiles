return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require "config/lualine"
    end,
  },
  {
    "echasnovski/mini.cursorword",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.cursorword").setup({ delay = 100 })
    end,
  },
  {
    "shellRaining/hlchunk.nvim",
    enabled = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = require "config/hlchunk",
  },
  { "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" }, opts = require "config/gitsigns" },
  { "uga-rosa/ccc.nvim", cmd = { "CccPick", "CccConvert", "CccHighlighterToggle" } },
  { "j-hui/fidget.nvim", event = "LspAttach", tag = "legacy", opts = {} },
}
