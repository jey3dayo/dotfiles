local wezterm = require "wezterm"
local scheme = wezterm.get_builtin_color_schemes()["nord"]
-- local utils = require "utils"
local keybinds = require "keybinds"
local gpus = wezterm.gui.enumerate_gpus()
require "on"

return {
  -- font = wezterm.font "Inconsolata Nerd Font Mono",
  -- font_size = 18,

  -- font = wezterm.font "Cica",
  -- font_size = 18,

  font = wezterm.font "UDEV Gothic 35NFLG",
  font_size = 16,

  -- font = wezterm.font "Hackgen35 Console NFJ",
  -- font_size = 15,

  use_ime = true,
  color_scheme = "kanagawa (Gogh)",
  -- color_scheme = "palenight (Gogh)",
  window_background_opacity = 0.88,
  adjust_window_size_when_changing_font_size = false,

  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = true,
  -- colors = {
  --   tab_bar = {
  --     background = scheme.background,
  --     new_tab = { bg_color = "#2e3440", fg_color = scheme.ansi[8], intensity = "Bold" },
  --     new_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.brights[8], intensity = "Bold" },
  --     -- -- format-tab-title
  --     -- active_tab = { bg_color = "#121212", fg_color = "#FCE8C3" },
  --     -- inactive_tab = { bg_color = scheme.background, fg_color = "#FCE8C3" },
  --     -- inactive_tab_hover = { bg_color = scheme.ansi[1], fg_color = "#FCE8C3" },
  --   },
  -- },

  enable_csi_u_key_encoding = true,
  leader = { key = "Space", mods = "CTRL|SHIFT" },
  keys = keybinds.create_keybinds(),
  key_tables = keybinds.key_tables,
  mouse_bindings = keybinds.mouse_bindings,

  -- https://github.com/wez/wezterm/issues/2756
  webgpu_preferred_adapter = gpus[1],
  front_end = "WebGpu",
}
