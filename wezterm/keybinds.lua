local wezterm = require "wezterm"
local utils = require "./utils"
local constants = require "./constants"
local key_tables = require "./key_tables"

local act = wezterm.action

local default_keybinds = {
  { key = "n", mods = "SUPER", action = act.SpawnWindow },
  { key = "w", mods = "SUPER", action = act { CloseCurrentTab = { confirm = true } } },
  { key = "q", mods = "SUPER", action = act.QuitApplication },
  { key = "F4", mods = "ALT", action = act.QuitApplication },
  { key = "Insert", mods = "SHIFT", action = act { PasteFrom = "PrimarySelection" } },
  { key = "=", mods = "CTRL|SHIFT", action = "ResetFontSize" },
  { key = "+", mods = "CTRL", action = "IncreaseFontSize" },
  { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
}

local tmux_keybinds = {
  { key = "c", mods = "LEADER", action = act.SpawnTab "CurrentPaneDomain" },
  { key = "x", mods = "LEADER", action = act { CloseCurrentPane = { confirm = true } } },
  { key = "n", mods = "LEADER", action = act { ActivateTabRelative = 1 } },
  { key = "p", mods = "LEADER", action = act { ActivateTabRelative = -1 } },
  { key = "o", mods = "LEADER", action = act.ActivatePaneDirection "Next" },
  { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "-", mods = "LEADER", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "Space", mods = "LEADER", action = act.RotatePanes "Clockwise" },

  -- Search
  { key = "Enter", mods = "LEADER", action = "QuickSelect" },
  { key = "/", mods = "LEADER", action = act.Search "CurrentSelectionOrEmptyString" },

  -- CopyMode
  {
    key = "[",
    mods = "LEADER",
    action = act.Multiple { act.CopyMode "ClearSelectionMode", act.ActivateCopyMode, act.ClearSelection },
  },
  { key = "]", mods = "LEADER", action = act { PasteFrom = "PrimarySelection" } },

  -- Resize Pane
  {
    key = "r",
    mods = "ALT",
    action = act.Multiple {
      act.EmitEvent "activate-resize-mode",
      act.ActivateKeyTable {
        name = "resize_pane",
        one_shot = false,
        timeout_milliseconds = 3000,
        replace_current = false,
      },
    },
  },

  -- Macros
  -- テキストを全ペーンに送信して、Ctrl+Enterで送信
  {
    key = "E",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      local tab = window:active_tab()
      -- 全てのペーンにテキストを送信
      for _, p in ipairs(tab:panes()) do
        -- SendStringでテキストを送信
        window:perform_action(act.SendString "続きを進めて", p)
        -- SendKeyでCtrl+Enterを送信（Claude Code送信用）
        window:perform_action(act.SendKey { key = "Enter", mods = "CTRL" }, p)
      end
    end),
  },
}

-- Opacity adjustment is now handled in events.lua

local wezterm_keybinds = {
  -- Tab
  { key = "Tab", mods = "ALT", action = act { ActivateTabRelative = 1 } },
  { key = "Tab", mods = "ALT|SHIFT", action = act { ActivateTabRelative = -1 } },
  { key = "h", mods = "ALT|CTRL", action = act { MoveTabRelative = -1 } },
  { key = "l", mods = "ALT|CTRL", action = act { MoveTabRelative = 1 } },

  -- Pane
  { key = "j", mods = "ALT", action = act { ActivatePaneDirection = "Down" } },
  { key = "k", mods = "ALT", action = act { ActivatePaneDirection = "Up" } },
  { key = "h", mods = "ALT", action = act { ActivatePaneDirection = "Left" } },
  { key = "l", mods = "ALT", action = act { ActivatePaneDirection = "Right" } },
  { key = "h", mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Left", 2 } } },
  { key = "l", mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Right", 2 } } },
  { key = "k", mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Up", 2 } } },
  { key = "j", mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Down", 2 } } },

  -- Window
  { key = "n", mods = "ALT", action = act { ActivateWindowRelative = 1 } },
  { key = "p", mods = "ALT", action = act { ActivateWindowRelative = -1 } },

  -- Show the launcher
  -- { key = "0",   mods = "ALT",            action = act.ShowLauncherArgs { flags = "FUZZY|COMMANDS" } },
  { key = "0", mods = "ALT", action = act.ShowLauncher },
}
-- LEADER/ALT + number to activate that window
for i = 1, 8 do
  table.insert(wezterm_keybinds, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1) })
end

local mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act { CompleteSelection = "PrimarySelection" },
  },
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act { CompleteSelection = "Clipboard" },
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "SUPER",
    action = "OpenLinkAtMouseCursor",
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = "OpenLinkAtMouseCursor",
  },
}

local windows_keybinds = {
  { key = "c", mods = "CTRL|SHIFT", action = wezterm.action { CopyTo = "Clipboard" } },
}

local function replaceCmdWithAlt(key)
  return {
    key = key,
    mods = "CMD",
    action = wezterm.action.SendKey { key = key, mods = "ALT" },
  }
end

-- CMDをALTに置換
local hack_keybinds = {
  replaceCmdWithAlt "k",
  replaceCmdWithAlt "i",
  replaceCmdWithAlt "l",
  replaceCmdWithAlt "p",
}

local keys = utils.array_concat(default_keybinds, tmux_keybinds, wezterm_keybinds, hack_keybinds)
if wezterm.target_triple:find "windows" then keys = utils.array_concat(keys, windows_keybinds) end

return {
  -- TODO: いつかtrueにする
  disable_default_key_bindings = false,
  leader = constants.leader,
  keys = keys,
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
