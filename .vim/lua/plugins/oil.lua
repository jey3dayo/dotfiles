local deps = require "core.dependencies"

return {
  "stevearc/oil.nvim",
  keys = { "<Leader>e", "<Leader>E" },
  config = function()
    require "config/oil"
  end,
  dependencies = deps.nvim_web_devicons,
}