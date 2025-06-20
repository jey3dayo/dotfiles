local wezterm = require "wezterm"
local utils = require "./utils"
local ui = require "./ui"
local keybinds = require "./keybinds"
local os = require "./os"
local events = require "./events"
local gpus = wezterm.gui.enumerate_gpus()

-- Register all event handlers
events.register_events()

local config = {
  use_ime = true,
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = true,
  enable_csi_u_key_encoding = false,
  -- https://github.com/wez/wezterm/issues/2756
  webgpu_preferred_adapter = gpus[1],
  front_end = "WebGpu",
}

return utils.object_assign(ui, keybinds, os, config)
