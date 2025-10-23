local wezterm = require "wezterm"
local utils = require "./utils"
local ui = require "./ui"
local keybinds = require "./keybinds"
local os = require "./os"
local events = require "./events"
local gpus = {}
if wezterm.gui and wezterm.gui.enumerate_gpus then gpus = wezterm.gui.enumerate_gpus() end

-- Register all event handlers
events.register_events()

local config = {
  use_ime = true,
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = true,
  enable_csi_u_key_encoding = false,
  front_end = "WebGpu",
  scrollback_lines = 5000,
}

-- https://github.com/wez/wezterm/issues/2756
if gpus and gpus[1] then config.webgpu_preferred_adapter = gpus[1] end

return utils.object_assign(ui, keybinds, os, config)
