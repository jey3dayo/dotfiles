local M = {}

-- Window opacity
M.DEFAULT_OPACITY = 0.92

-- Colors
M.colors = {
  grey = "#0f1419",
  light_grey = "#191f26",
  dark = "#222",
  light = "#EEE",
  primary = "#778AC5",
}

-- Tab bar colors
M.tab_bar = {
  bg = M.colors.dark,
  active_bg = M.colors.primary,
  active_fg = M.colors.dark,
  hover_bg = M.colors.grey,
  hover_fg = M.colors.light,
  normal_bg = M.colors.light_grey,
  normal_fg = M.colors.light,
}

-- Icons
M.icons = {
  solid_right_arrow = utf8.char(0xe0b0),
}

-- Font settings
M.font = {
  name = "UDEV Gothic 35NFLG",
  size = 16,
  fallbacks = { "Inconsolata Nerd Font Mono", "Noto Color Emoji" },
}

-- Window settings
M.window = {
  initial_cols = 180,
  initial_rows = 50,
  decorations = "RESIZE",
  padding = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- Tab settings
M.tab = {
  max_width = 32,
  enable_bar = true,
  hide_if_only_one = false,
  bar_at_bottom = true,
  use_fancy_bar = false,
}

-- Key bindings
M.leader = {
  key = "x",
  mods = "CTRL",
  timeout_milliseconds = 1000,
}

-- Pane appearance settings
M.pane = {
  inactive_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 0.7,
  },
}

-- Platform-specific settings
M.windows = {
  font_size = 12,
  initial_cols = 130,
  initial_rows = 30,
  decorations = "TITLE",
}

return M
