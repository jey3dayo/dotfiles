local utils = require "core.utils"
if not utils then return {} end

local get_os = utils.get_os
local with = utils.with

local base_config = {
  set_default_events = { "VimEnter", "InsertLeave", "CmdlineLeave" },
}

local config = {
  mac = with(base_config, {
    default_im_select = "com.apple.keylayout.ABC",
  }),
  windows = with(base_config, {
    -- default_im_select = "1033",
    default_im_select = "ms.inputmethod.atok33.Roman",
    default_command = "im-select.exe",
  }),
  wsl = {},
  linux = with(base_config, {
    default_im_select = "1",
    default_command = "fcitx5-remote",
  }),
}

return config[get_os()] or {}
