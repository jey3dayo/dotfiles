local wezterm = require "wezterm"
local utils = require "./utils"

-- local opacity = 1
local opacity = 0.92

local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

local Grey = "#0f1419"
local LightGrey = "#191f26"
local Dark = "#222"
local Light = "#EEE"
local PrimaryColor = "#778AC5"
local TAB_BAR_BG = Dark
local ACTIVE_TAB_BG = PrimaryColor
local ACTIVE_TAB_FG = Dark
local HOVER_TAB_BG = Grey
local HOVER_TAB_FG = Light
local NORMAL_TAB_BG = LightGrey
local NORMAL_TAB_FG = Light

-- luacheck: ignore panes config
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  max_width = max_width

  local background = NORMAL_TAB_BG
  local foreground = NORMAL_TAB_FG

  local is_first = tab.tab_id == tabs[1].tab_id
  local is_last = tab.tab_id == tabs[#tabs].tab_id

  if tab.is_active then
    background = ACTIVE_TAB_BG
    foreground = ACTIVE_TAB_FG
  elseif hover then
    background = HOVER_TAB_BG
    foreground = HOVER_TAB_FG
  end

  local leading_fg = NORMAL_TAB_BG
  local leading_bg = background

  local trailing_fg = background
  local trailing_bg = NORMAL_TAB_BG

  if is_first or is_last then
    leading_fg = TAB_BAR_BG
    trailing_bg = TAB_BAR_BG
  end

  local title = utils.truncate_right(tab.active_pane.foreground_process_name, max_width)
  if title == "" then
    local cwd = tab.active_pane.current_working_dir
    if type(cwd) == "table" and cwd.file_path then
      cwd = cwd.file_path
    elseif type(cwd) ~= "string" then
      cwd = tostring(cwd)
    end
    title = utils.truncate_right(utils.convert_home_dir(cwd), max_width)
  end

  return {
    { Attribute = { Italic = false } },
    { Attribute = { Intensity = hover and "Bold" or "Normal" } },
    { Background = { Color = leading_bg } },
    { Foreground = { Color = leading_fg } },
    { Text = SOLID_RIGHT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = tab.tab_index + 1 .. ":" .. title },
    { Background = { Color = trailing_bg } },
    { Foreground = { Color = trailing_fg } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

-- Workspace
-- wezterm.on("update-right-status", function(window, _)
--   window:set_right_status("[" .. window:active_workspace() .. "]")
-- end)

return {
  -- Window
  color_scheme = "Gruvbox dark, hard (base16)",
  font = utils.font_with_fallback "UDEV Gothic 35NFLG",
  font_size = 16,
  -- font = utils.font_with_fallback "JetBrainsMono Nerd Font Mono",
  -- font_size = 17,
  window_background_opacity = opacity,
  text_background_opacity = opacity,
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
  colors = { tab_bar = { background = TAB_BAR_BG } },
  tab_bar_style = {
    new_tab = wezterm.format {
      { Background = { Color = TAB_BAR_BG } },
      { Foreground = { Color = TAB_BAR_BG } },
      { Text = SOLID_RIGHT_ARROW },
      { Background = { Color = ACTIVE_TAB_BG } },
      { Foreground = { Color = NORMAL_TAB_BG } },
      { Text = " + " },
      { Background = { Color = TAB_BAR_BG } },
      { Foreground = { Color = ACTIVE_TAB_BG } },
      { Text = SOLID_RIGHT_ARROW },
    },
    new_tab_hover = wezterm.format {
      { Attribute = { Italic = false } },
      { Attribute = { Intensity = "Bold" } },
      { Background = { Color = NORMAL_TAB_BG } },
      { Foreground = { Color = TAB_BAR_BG } },
      { Text = SOLID_RIGHT_ARROW },
      { Background = { Color = NORMAL_TAB_BG } },
      { Foreground = { Color = NORMAL_TAB_FG } },
      { Text = " + " },
      { Background = { Color = TAB_BAR_BG } },
      { Foreground = { Color = NORMAL_TAB_BG } },
      { Text = SOLID_RIGHT_ARROW },
    },
  },
}
