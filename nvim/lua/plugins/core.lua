local deps = require "core.dependencies"
local function dep(spec)
  return vim.deepcopy(spec)
end

return {
  dep(deps.plenary),
  dep(deps.sqlite),
  dep(deps.devicons),
  dep(deps.icons),
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
    config = function()
      require "config/vim-repeat"
    end,
  },
}
