local wezterm = require "wezterm"
local utils = require "./utils"
local ui = require "./ui"
local keybinds = require "./keybinds"
local os_config = require "./os"
local events = require "./events"

-- Register all event handlers before building the final config
events.register_events()

-- Start from the builder so wezterm can apply defaults and validation
local config = wezterm.config_builder and wezterm.config_builder() or {}

local base_config = {
  use_ime = true,
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = true,
  enable_csi_u_key_encoding = false,
  front_end = "OpenGL",
  max_fps = 60,
  scrollback_lines = 5000,
}

if wezterm.gui and wezterm.gui.enumerate_gpus then
  local gpus = wezterm.gui.enumerate_gpus()
  -- https://github.com/wez/wezterm/issues/2756
  if gpus and gpus[1] then base_config.webgpu_preferred_adapter = gpus[1] end
end

utils.merge_tables(config, base_config)
utils.merge_tables(config, ui)
utils.merge_tables(config, keybinds)
utils.merge_tables(config, os_config)

return config
