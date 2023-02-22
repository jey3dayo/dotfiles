local wezterm = require "wezterm"
local keybinds = require "./keybinds"
local ui = require "./ui"
local utils = require "./utils"
local gpus = wezterm.gui.enumerate_gpus()
require "./on"

local config = {
  use_ime = true,
  enable_csi_u_key_encoding = true,
  leader = keybinds.leader,
  keys = keybinds.create_keybinds(),
  key_tables = keybinds.key_tables,
  mouse_bindings = keybinds.mouse_bindings,
  -- https://github.com/wez/wezterm/issues/2756
  webgpu_preferred_adapter = gpus[1],
  front_end = "WebGpu",
}

return utils.merge_tables(ui, config)
