local deps = require "core.dependencies"

return {
  -- Telescope disabled - replaced by mini.pick
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
    cmd = "Telescope",
    dependencies = deps.plenary,
    config = function()
      require "config/telescope"
    end,
  },
  -- Frecency disabled - replaced by mini.pick
  {
    "nvim-telescope/telescope-frecency.nvim",
    enabled = false,
    keys = { "<Leader>f", "<Leader>F", "<A-p>" },
    dependencies = deps.telescope,
    opts = {
      db_safe_mode = false,
    },
  },
  -- Neoclip kept for now (fallback until mini.pick yank history implemented)
  {
    "AckslD/nvim-neoclip.lua",
    keys = { "<Leader>Y" },
    dependencies = { "nvim-telescope/telescope.nvim", "kkharji/sqlite.lua" },
    opts = require "config/neoclip",
  },
  require "plugins/oil",
}
