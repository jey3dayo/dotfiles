local deps = require "core.dependencies"

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = deps.plenary,
    config = function()
      require "config/telescope"
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = { "<Leader>e", "<Leader>E" },
    dependencies = deps.telescope,
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    keys = { "<Leader>f", "<Leader>F", "<A-p>" },
    dependencies = deps.telescope,
    opts = {
      db_safe_mode = false,
    },
  },
  {
    "AckslD/nvim-neoclip.lua",
    keys = { "<Leader>Y" },
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    opts = require "config/neoclip",
  },
  {
    "debugloop/telescope-undo.nvim",
    keys = { "<Leader>u" },
    dependencies = deps.telescope,
  },
}
