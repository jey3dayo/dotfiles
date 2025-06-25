local wezterm = require "wezterm"
local constants = require "./constants"
local utils = require "./utils"

local M = {}

-- Format tab title
function M.format_tab_title(tab, tabs, _, _, hover, max_width)
  max_width = max_width

  local background = constants.tab_bar.normal_bg
  local foreground = constants.tab_bar.normal_fg

  local is_first = tab.tab_id == tabs[1].tab_id
  local is_last = tab.tab_id == tabs[#tabs].tab_id

  if tab.is_active then
    background = constants.tab_bar.active_bg
    foreground = constants.tab_bar.active_fg
  elseif hover then
    background = constants.tab_bar.hover_bg
    foreground = constants.tab_bar.hover_fg
  end

  local leading_fg = constants.tab_bar.normal_bg
  local leading_bg = background

  local trailing_fg = background
  local trailing_bg = constants.tab_bar.normal_bg

  if is_first or is_last then
    leading_fg = constants.tab_bar.bg
    trailing_bg = constants.tab_bar.bg
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
    { Text = constants.icons.solid_right_arrow },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = tab.tab_index + 1 .. ":" .. title },
    { Background = { Color = trailing_bg } },
    { Foreground = { Color = trailing_fg } },
    { Text = constants.icons.solid_right_arrow },
  }
end

-- Opacity adjustment handlers
function M.increase_opacity(window, _)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then overrides.window_background_opacity = constants.DEFAULT_OPACITY end
  overrides.window_background_opacity = math.min(overrides.window_background_opacity + 0.05, 1.0)
  overrides.text_background_opacity = overrides.window_background_opacity
  window:set_config_overrides(overrides)
  window:toast_notification(
    "wezterm",
    string.format("Opacity: %.0f%%", overrides.window_background_opacity * 100),
    nil,
    1000
  )
end

function M.decrease_opacity(window, _)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then overrides.window_background_opacity = constants.DEFAULT_OPACITY end
  overrides.window_background_opacity = math.max(overrides.window_background_opacity - 0.05, 0.1)
  overrides.text_background_opacity = overrides.window_background_opacity
  window:set_config_overrides(overrides)
  window:toast_notification(
    "wezterm",
    string.format("Opacity: %.0f%%", overrides.window_background_opacity * 100),
    nil,
    1000
  )
end

function M.reset_opacity(window, _)
  local overrides = window:get_config_overrides() or {}
  overrides.window_background_opacity = constants.DEFAULT_OPACITY
  overrides.text_background_opacity = constants.DEFAULT_OPACITY
  window:set_config_overrides(overrides)
  window:toast_notification(
    "wezterm",
    string.format("Opacity: %.0f%% (reset)", constants.DEFAULT_OPACITY * 100),
    nil,
    1000
  )
end


-- Status update handler for showing mode indicators
function M.update_status(window, pane)
  -- This will be overridden by keybinds.lua to show resize mode status
end

-- Register all event handlers
function M.register_events()
  wezterm.on("format-tab-title", M.format_tab_title)
  wezterm.on("increase-opacity", M.increase_opacity)
  wezterm.on("decrease-opacity", M.decrease_opacity)
  wezterm.on("reset-opacity", M.reset_opacity)
  wezterm.on("update-status", M.update_status)
end

return M
