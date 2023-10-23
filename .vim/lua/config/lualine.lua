local status, lualine = pcall(require, "lualine")
if not status then
  return
end

-- local config = require "config.lualine.powerline"
local config = require "config.lualine.evil"

lualine.setup(config)
