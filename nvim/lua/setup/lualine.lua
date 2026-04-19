local utils = require "core.utils"
local lualine = utils.safe_require "lualine"

if not lualine then return end

lualine.setup(require "config.lualine.evil")
