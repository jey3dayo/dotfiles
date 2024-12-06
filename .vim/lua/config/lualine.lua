local lualine = Safe_require "lualine"

if not lualine then
  return
end

-- local config = require "config.lualine.powerline"
local config = require "config.lualine.evil"

lualine.setup(config)
