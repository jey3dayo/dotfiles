local utils = require "core.utils"
local rainbow_delimiters = utils.safe_require "rainbow-delimiters.setup"
if not rainbow_delimiters then return end

local function safe_global_strategy(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return nil end
  return require "rainbow-delimiters.strategy.global"
end

rainbow_delimiters.setup {
  strategy = {
    [""] = safe_global_strategy,
    vim = "rainbow-delimiters.strategy.local",
  },
  query = {
    [""] = "rainbow-delimiters",
    lua = "rainbow-blocks",
  },
  priority = {
    [""] = 110,
    lua = 210,
  },
  highlight = {
    "RainbowDelimiterRed",
    "RainbowDelimiterYellow",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterGreen",
    "RainbowDelimiterViolet",
    "RainbowDelimiterCyan",
  },
}
