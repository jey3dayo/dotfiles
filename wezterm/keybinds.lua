local wezterm = require "wezterm"
local utils = require "./utils"
local constants = require "./constants"

local act = wezterm.action

-- Resize mode state
local resize_mode_active = false

-- Track resize mode activation
wezterm.on("activate-resize-mode", function(window, pane)
  resize_mode_active = true
  window:set_right_status " 🔧 RESIZE "
  window:toast_notification("wezterm", "Resize mode activated", nil, 1000)

  -- Set a timer to clear the status after timeout
  wezterm.time.call_after(3, function()
    if resize_mode_active then
      resize_mode_active = false
      window:set_right_status ""
    end
  end)
end)

-- Track resize mode deactivation
wezterm.on("deactivate-resize-mode", function(window, pane)
  resize_mode_active = false
  window:set_right_status ""
end)

-- Update status on various events
wezterm.on("update-status", function(window, pane)
  if resize_mode_active then
    window:set_right_status " 🔧 RESIZE "
  else
    window:set_right_status ""
  end
end)

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

local key_tables = {
  -- ALT+r -> [j, k, h, l] and [+, -] for opacity
  resize_pane = {
    { key = "h", action = act { AdjustPaneSize = { "Left", 1 } } },
    { key = "l", action = act { AdjustPaneSize = { "Right", 1 } } },
    { key = "k", action = act { AdjustPaneSize = { "Up", 1 } } },
    { key = "j", action = act { AdjustPaneSize = { "Down", 1 } } },

    -- Opacity adjustment (will exit resize mode, but that's WezTerm limitation)
    { key = "+", action = act { EmitEvent = "increase-opacity" } },
    { key = "-", action = act { EmitEvent = "decrease-opacity" } },
    { key = "0", action = act { EmitEvent = "reset-opacity" } },

    -- Cancel the mode by pressing escape
    { key = "Escape", action = act.Multiple { act.PopKeyTable, act.EmitEvent "deactivate-resize-mode" } },
    { key = "c", mods = "CTRL", action = act.Multiple { act.PopKeyTable, act.EmitEvent "deactivate-resize-mode" } },
    { key = "q", action = act.Multiple { act.PopKeyTable, act.EmitEvent "deactivate-resize-mode" } },
  },
  copy_mode = {
    {
      key = "q",
      mods = "NONE",
      action = act.Multiple {
        act.ClearSelection,
        act.CopyMode "ClearPattern",
        act.CopyMode "Close",
      },
    },
    {
      key = "Escape",
      mods = "NONE",
      action = act.Multiple {
        act.ClearSelection,
        act.CopyMode "ClearPattern",
        act.CopyMode "Close",
      },
    },
    {
      key = "c",
      mods = "CTRL",
      action = act.Multiple {
        act.ClearSelection,
        act.CopyMode "ClearPattern",
        act.CopyMode "Close",
      },
    },

    -- move cursor
    { key = "h", mods = "NONE", action = act.CopyMode "MoveLeft" },
    { key = "j", mods = "NONE", action = act.CopyMode "MoveDown" },
    { key = "k", mods = "NONE", action = act.CopyMode "MoveUp" },
    { key = "l", mods = "NONE", action = act.CopyMode "MoveRight" },

    -- move word
    { key = "w", mods = "NONE", action = act.CopyMode "MoveForwardWord" },
    { key = "\t", mods = "NONE", action = act.CopyMode "MoveForwardWord" },
    { key = "b", mods = "NONE", action = act.CopyMode "MoveBackwardWord" },
    { key = "\t", mods = "SHIFT", action = act.CopyMode "MoveBackwardWord" },
    {
      key = "e",
      mods = "NONE",
      action = act {
        Multiple = {
          act.CopyMode "MoveRight",
          act.CopyMode "MoveForwardWord",
          act.CopyMode "MoveLeft",
        },
      },
    },

    -- move start/end
    { key = "0", mods = "NONE", action = act.CopyMode "MoveToStartOfLine" },
    { key = "a", mods = "CTRL", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "^", mods = "SHIFT", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "^", mods = "NONE", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "e", mods = "CTRL", action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "$", mods = "SHIFT", action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "$", mods = "NONE", action = act.CopyMode "MoveToEndOfLineContent" },

    -- select
    { key = " ", mods = "NONE", action = act.CopyMode { SetSelectionMode = "Cell" } },
    { key = "v", mods = "NONE", action = act.CopyMode { SetSelectionMode = "Cell" } },
    {
      key = "v",
      mods = "SHIFT",
      action = act {
        Multiple = {
          act.CopyMode "MoveToStartOfLineContent",
          act.CopyMode { SetSelectionMode = "Cell" },
          act.CopyMode "MoveToEndOfLineContent",
        },
      },
    },

    -- copy
    {
      key = "y",
      mods = "NONE",
      action = act {
        Multiple = {
          act { CopyTo = "ClipboardAndPrimarySelection" },
          act.CopyMode "ClearPattern",
          act.CopyMode "Close",
        },
      },
    },
    {
      key = "y",
      mods = "SHIFT",
      action = act {
        Multiple = {
          act.CopyMode { SetSelectionMode = "Cell" },
          act.CopyMode "MoveToEndOfLineContent",
          act { CopyTo = "ClipboardAndPrimarySelection" },
          act.CopyMode "ClearPattern",
          act.CopyMode "Close",
        },
      },
    },

    -- scroll
    { key = "G", mods = "SHIFT", action = act.CopyMode "MoveToScrollbackBottom" },
    { key = "G", mods = "NONE", action = act.CopyMode "MoveToScrollbackBottom" },
    { key = "g", mods = "NONE", action = act.CopyMode "MoveToScrollbackTop" },
    { key = "H", mods = "NONE", action = act.CopyMode "MoveToViewportTop" },
    { key = "H", mods = "SHIFT", action = act.CopyMode "MoveToViewportTop" },
    { key = "M", mods = "NONE", action = act.CopyMode "MoveToViewportMiddle" },
    { key = "M", mods = "SHIFT", action = act.CopyMode "MoveToViewportMiddle" },
    { key = "L", mods = "NONE", action = act.CopyMode "MoveToViewportBottom" },
    { key = "L", mods = "SHIFT", action = act.CopyMode "MoveToViewportBottom" },
    { key = "o", mods = "NONE", action = act.CopyMode "MoveToSelectionOtherEnd" },
    { key = "O", mods = "NONE", action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
    { key = "O", mods = "SHIFT", action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
    { key = "PageUp", mods = "NONE", action = act.CopyMode "PageUp" },
    { key = "PageDown", mods = "NONE", action = act.CopyMode "PageDown" },
    { key = "b", mods = "CTRL", action = act.CopyMode "PageUp" },
    { key = "f", mods = "CTRL", action = act.CopyMode "PageDown" },
    {
      key = "Enter",
      mods = "NONE",
      action = act.CopyMode "ClearSelectionMode",
    },

    -- search
    { key = "/", mods = "NONE", action = act.Search "CurrentSelectionOrEmptyString" },
    {
      key = "n",
      mods = "NONE",
      action = act.Multiple {
        act.CopyMode "NextMatch",
        act.CopyMode "ClearSelectionMode",
      },
    },
    {
      key = "N",
      mods = "SHIFT",
      action = act.Multiple {
        act.CopyMode "PriorMatch",
        act.CopyMode "ClearSelectionMode",
      },
    },
  },
  search_mode = {
    { key = "Escape", mods = "NONE", action = act.CopyMode "Close" },
    {
      key = "Enter",
      mods = "NONE",
      action = act.Multiple {
        act.CopyMode "ClearSelectionMode",
        act.ActivateCopyMode,
      },
    },
    { key = "p", mods = "CTRL", action = act.CopyMode "PriorMatch" },
    { key = "n", mods = "CTRL", action = act.CopyMode "NextMatch" },
    { key = "r", mods = "CTRL", action = act.CopyMode "CycleMatchType" },
    { key = "/", mods = "NONE", action = act.CopyMode "ClearPattern" },
    { key = "u", mods = "CTRL", action = act.CopyMode "ClearPattern" },
  },
}

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
