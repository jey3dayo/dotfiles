local wezterm = require "wezterm"
local constants = require "./constants"
local utils = require "./utils"

local M = {}
local resize_mode_active = false

local function tab_colors(tab, hover)
  if tab.is_active then return constants.tab_bar.active_bg, constants.tab_bar.active_fg end
  if hover then return constants.tab_bar.hover_bg, constants.tab_bar.hover_fg end
  return constants.tab_bar.normal_bg, constants.tab_bar.normal_fg
end

local function edge_colors(tab, tabs, background)
  if not tabs or #tabs == 0 then
    return background, constants.tab_bar.normal_bg, constants.tab_bar.normal_bg, background
  end

  local is_first = tab.tab_id == tabs[1].tab_id
  local is_last = tab.tab_id == tabs[#tabs].tab_id

  local leading_fg = is_first and constants.tab_bar.bg or constants.tab_bar.normal_bg
  local trailing_bg = is_last and constants.tab_bar.bg or constants.tab_bar.normal_bg

  return background, leading_fg, trailing_bg, background
end

local function arrow_segment(bg, fg)
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = constants.icons.solid_right_arrow },
  }
end

local function title_segment(bg, fg, text)
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = text },
  }
end

-- Format tab title
function M.format_tab_title(tab, tabs, _, _, hover, max_width)
  local background, foreground = tab_colors(tab, hover)
  local leading_bg, leading_fg, trailing_bg, trailing_fg = edge_colors(tab, tabs, background)
  local tab_title = utils.tab_title_from_pane(tab.active_pane, max_width)
  local label = string.format("%d:%s", tab.tab_index + 1, tab_title)

  return utils.array_concat(
    {
      { Attribute = { Italic = false } },
      { Attribute = { Intensity = hover and "Bold" or "Normal" } },
    },
    arrow_segment(leading_bg, leading_fg),
    title_segment(background, foreground, label),
    arrow_segment(trailing_bg, trailing_fg)
  )
end

local function set_resize_status(window, active)
  resize_mode_active = active
  window:set_right_status(active and " 🔧 RESIZE " or "")
end

-- Resize mode handlers
function M.activate_resize_mode(window, _)
  set_resize_status(window, true)
  window:toast_notification("wezterm", "Resize mode activated", nil, 1000)

  wezterm.time.call_after(3, function()
    if resize_mode_active then set_resize_status(window, false) end
  end)
end

function M.deactivate_resize_mode(window, _)
  set_resize_status(window, false)
end

local function apply_opacity(window, delta)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then overrides.window_background_opacity = constants.DEFAULT_OPACITY end

  if delta then
    overrides.window_background_opacity = math.min(math.max(overrides.window_background_opacity + delta, 0.1), 1.0)
  else
    overrides.window_background_opacity = constants.DEFAULT_OPACITY
  end

  overrides.text_background_opacity = overrides.window_background_opacity
  window:set_config_overrides(overrides)

  return overrides.window_background_opacity
end

local function notify_opacity(window, opacity, suffix)
  window:toast_notification("wezterm", string.format("Opacity: %.0f%%%s", opacity * 100, suffix or ""), nil, 1000)
end

-- Opacity adjustment handlers
function M.increase_opacity(window, _)
  notify_opacity(window, apply_opacity(window, 0.05))
end

function M.decrease_opacity(window, _)
  notify_opacity(window, apply_opacity(window, -0.05))
end

function M.reset_opacity(window, _)
  notify_opacity(window, apply_opacity(window), " (reset)")
end

-- Status update handler for showing mode indicators
function M.update_status(window, pane)
  if resize_mode_active then
    window:set_right_status " 🔧 RESIZE "
  else
    window:set_right_status ""
  end
end

-- Register all event handlers
function M.register_events()
  wezterm.on("format-tab-title", M.format_tab_title)
  wezterm.on("activate-resize-mode", M.activate_resize_mode)
  wezterm.on("deactivate-resize-mode", M.deactivate_resize_mode)
  wezterm.on("increase-opacity", M.increase_opacity)
  wezterm.on("decrease-opacity", M.decrease_opacity)
  wezterm.on("reset-opacity", M.reset_opacity)
  wezterm.on("update-status", M.update_status)
end

return M
