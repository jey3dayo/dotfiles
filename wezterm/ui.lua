local wezterm = require "wezterm"
local utils = require "./utils"
local constants = require "./constants"

-- Tab formatting is now handled in events.lua

return {
  -- Window
  color_scheme = "Gruvbox dark, hard (base16)",
  font = utils.font_with_fallback(constants.font.name),
  font_size = constants.font.size,
  -- font = utils.font_with_fallback "JetBrainsMono Nerd Font Mono",
  -- font_size = 17,
  window_background_opacity = constants.DEFAULT_OPACITY,
  text_background_opacity = constants.DEFAULT_OPACITY,
  window_decorations = constants.window.decorations,
  native_macos_fullscreen_mode = true,
  window_padding = constants.window.padding,
  initial_cols = constants.window.initial_cols,
  initial_rows = constants.window.initial_rows,
  adjust_window_size_when_changing_font_size = false,
  -- Tab
  enable_tab_bar = constants.tab.enable_bar,
  hide_tab_bar_if_only_one_tab = constants.tab.hide_if_only_one,
  tab_bar_at_bottom = constants.tab.bar_at_bottom,
  tab_max_width = constants.tab.max_width,
  use_fancy_tab_bar = constants.tab.use_fancy_bar,
  colors = { tab_bar = { background = constants.tab_bar.bg } },
  tab_bar_style = {
    new_tab = wezterm.format {
      { Background = { Color = constants.tab_bar.bg } },
      { Foreground = { Color = constants.tab_bar.bg } },
      { Text = constants.icons.solid_right_arrow },
      { Background = { Color = constants.tab_bar.active_bg } },
      { Foreground = { Color = constants.tab_bar.normal_bg } },
      { Text = " + " },
      { Background = { Color = constants.tab_bar.bg } },
      { Foreground = { Color = constants.tab_bar.active_bg } },
      { Text = constants.icons.solid_right_arrow },
    },
    new_tab_hover = wezterm.format {
      { Attribute = { Italic = false } },
      { Attribute = { Intensity = "Bold" } },
      { Background = { Color = constants.tab_bar.normal_bg } },
      { Foreground = { Color = constants.tab_bar.bg } },
      { Text = constants.icons.solid_right_arrow },
      { Background = { Color = constants.tab_bar.normal_bg } },
      { Foreground = { Color = constants.tab_bar.normal_fg } },
      { Text = " + " },
      { Background = { Color = constants.tab_bar.bg } },
      { Foreground = { Color = constants.tab_bar.normal_bg } },
      { Text = constants.icons.solid_right_arrow },
    },
  },
}
