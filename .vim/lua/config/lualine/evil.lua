-- Eviline config for lualine (Refactored)
-- Author: shadmansaleh
-- Credit: glepnir
-- Refactored into modular components

local colors = require "config.lualine.colors"
local components = require "config.lualine.components"

-- Config
local config = {
  options = {
    component_separators = "",
    section_separators = "",
    theme = {
      normal = { c = { fg = colors.colors.fg, bg = colors.colors.bg } },
      inactive = { c = { fg = colors.colors.fg, bg = colors.colors.bg } },
    },
  },
  sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = components.left_components,
    lualine_x = components.right_components,
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_y = {},
    lualine_z = {},
    lualine_c = {},
    lualine_x = {},
  },
}

return config
