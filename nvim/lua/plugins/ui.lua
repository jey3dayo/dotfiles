local deps = require "core.dependencies"

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = deps.icons,
    config = function()
      require "config/lualine"
    end,
  },
  {
    "echasnovski/mini.cursorword",
    version = false,
    event = "VeryLazy",
    opts = { delay = 100 },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = require "config/gitsigns",
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
}
