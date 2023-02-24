local wezterm = require "wezterm"
local utils = require "./utils"
local ui = require "./ui"
local keybinds = require "./keybinds"
local gpus = wezterm.gui.enumerate_gpus()

local config = {
  use_ime = true,
  enable_csi_u_key_encoding = true,
  -- https://github.com/wez/wezterm/issues/2756
  webgpu_preferred_adapter = gpus[1],
  front_end = "WebGpu",
}

return utils.object_assign(config, ui, keybinds)
