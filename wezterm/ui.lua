local wezterm = require "wezterm"
local scheme = wezterm.get_builtin_color_schemes()["nord"]
local utils = require "./utils"

return {
  -- Theme
  color_scheme = "Gruvbox dark, hard (base16)",
  font = utils.font_with_fallback "UDEV Gothic 35NFLG",
  font_size = 16,
  -- Window
  -- dpi = 96.0,
  window_background_opacity = 0.9,
  text_background_opacity = 0.9,
  window_decorations = "RESIZE",
  native_macos_fullscreen_mode = true,
  window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
  initial_cols = 180,
  initial_rows = 50,
  adjust_window_size_when_changing_font_size = false,
  -- Tab
  enable_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = true,
  tab_max_width = 32,
  use_fancy_tab_bar = false,
  colors = {
    tab_bar = {
      background = scheme.background,
      new_tab = { bg_color = "#2e3440", fg_color = scheme.ansi[8], intensity = "Bold" },
      new_tab_hover = { bg_color = scheme.ansi[1], fg_color = scheme.brights[8], intensity = "Bold" },

      -- format-tab-title
      active_tab = { bg_color = "#121212", fg_color = "#FCE8C3" },
      inactive_tab = { bg_color = scheme.background, fg_color = "#FCE8C3" },
      inactive_tab_hover = { bg_color = scheme.ansi[1], fg_color = "#FCE8C3" },
    },
  },
}
