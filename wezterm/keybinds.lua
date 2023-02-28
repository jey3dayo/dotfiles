local wezterm = require "wezterm"
local act = wezterm.action
local utils = require "./utils"

local default_keybinds = {
  { key = "w",      mods = "SUPER",      action = act { CloseCurrentPane = { confirm = true } } },
  { key = "n",      mods = "SUPER",      action = act { SpawnTab = "CurrentPaneDomain" } },
  { key = "q",      mods = "SUPER",      action = act.QuitApplication },
  { key = "F4",     mods = "ALT",        action = act.QuitApplication },
  { key = "Insert", mods = "SHIFT",      action = act { PasteFrom = "PrimarySelection" } },
  { key = "=",      mods = "CTRL|SHIFT", action = "ResetFontSize" },
  { key = "+",      mods = "CTRL",       action = "IncreaseFontSize" },
  { key = "-",      mods = "CTRL",       action = "DecreaseFontSize" },
}

local tmux_keybinds = {
  { key = "c",     mods = "LEADER",       action = act { SpawnTab = "CurrentPaneDomain" } },
  { key = "x",     mods = "LEADER",       action = act { CloseCurrentTab = { confirm = true } } },
  { key = "n",     mods = "LEADER",       action = act { ActivateTabRelative = 1 } },
  { key = "p",     mods = "LEADER",       action = act { ActivateTabRelative = -1 } },
  { key = "o",     mods = "LEADER",       action = act.ActivatePaneDirection "Next" },
  { key = '"',     mods = "LEADER|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "-",     mods = "LEADER",       action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "|",     mods = "LEADER|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "z",     mods = "LEADER",       action = act.TogglePaneZoomState },
  { key = "Space", mods = "LEADER",       action = act.RotatePanes "Clockwise" },
  { key = "1",     mods = "LEADER",       action = act { ActivateTab = 0 } }, -- {{{
  { key = "2",     mods = "LEADER",       action = act { ActivateTab = 1 } },
  { key = "3",     mods = "LEADER",       action = act { ActivateTab = 2 } },
  { key = "4",     mods = "LEADER",       action = act { ActivateTab = 3 } },
  { key = "5",     mods = "LEADER",       action = act { ActivateTab = 4 } },
  { key = "6",     mods = "LEADER",       action = act { ActivateTab = 5 } },
  { key = "7",     mods = "LEADER",       action = act { ActivateTab = 6 } },
  { key = "8",     mods = "LEADER",       action = act { ActivateTab = 7 } },
  { key = "9",     mods = "LEADER",       action = act { ActivateTab = 8 } }, -- }}}

  -- Search
  { key = "Enter", mods = "LEADER",       action = "QuickSelect" },
  { key = "/",     mods = "LEADER",       action = act.Search "CurrentSelectionOrEmptyString" },

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
    action = act {
      ActivateKeyTable = {
        name = "resize_pane",
        one_shot = false,
        timeout_milliseconds = 3000,
        replace_current = false,
      },
    },
  },
}

local wezterm_keybinds = {
  -- Tab
  { key = "Tab", mods = "ALT",            action = act { ActivateTabRelative = 1 } },
  { key = "Tab", mods = "ALT|SHIFT",      action = act { ActivateTabRelative = -1 } },
  { key = "n",   mods = "ALT",            action = act { ActivateTabRelative = 1 } },
  { key = "p",   mods = "ALT",            action = act { ActivateTabRelative = -1 } },
  { key = "h",   mods = "ALT|CTRL",       action = act { MoveTabRelative = -1 } },
  { key = "l",   mods = "ALT|CTRL",       action = act { MoveTabRelative = 1 } },
  { key = "1",   mods = "ALT",            action = act { ActivateTab = 0 } }, -- {{{
  { key = "2",   mods = "ALT",            action = act { ActivateTab = 1 } },
  { key = "3",   mods = "ALT",            action = act { ActivateTab = 2 } },
  { key = "4",   mods = "ALT",            action = act { ActivateTab = 3 } },
  { key = "5",   mods = "ALT",            action = act { ActivateTab = 4 } },
  { key = "6",   mods = "ALT",            action = act { ActivateTab = 5 } },
  { key = "7",   mods = "ALT",            action = act { ActivateTab = 6 } },
  { key = "8",   mods = "ALT",            action = act { ActivateTab = 7 } },
  { key = "9",   mods = "ALT",            action = act { ActivateTab = 8 } }, -- }}}

  -- Pane
  { key = "j",   mods = "ALT",            action = act { ActivatePaneDirection = "Down" } },
  { key = "k",   mods = "ALT",            action = act { ActivatePaneDirection = "Up" } },
  { key = "h",   mods = "ALT",            action = act { ActivatePaneDirection = "Left" } },
  { key = "l",   mods = "ALT",            action = act { ActivatePaneDirection = "Right" } },
  { key = "h",   mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Left", 1 } } },
  { key = "l",   mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Right", 1 } } },
  { key = "k",   mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Up", 1 } } },
  { key = "j",   mods = "ALT|SHIFT|CTRL", action = act { AdjustPaneSize = { "Down", 1 } } },
}

local key_tables = {
  resize_pane = {
    { key = "h",      action = act { AdjustPaneSize = { "Left", 1 } } },
    { key = "l",      action = act { AdjustPaneSize = { "Right", 1 } } },
    { key = "k",      action = act { AdjustPaneSize = { "Up", 1 } } },
    { key = "j",      action = act { AdjustPaneSize = { "Down", 1 } } },

    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },
  copy_mode = {
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
    { key = "q",  mods = "NONE",  action = act.CopyMode "Close" },

    -- move cursor
    { key = "h",  mods = "NONE",  action = act.CopyMode "MoveLeft" },
    { key = "j",  mods = "NONE",  action = act.CopyMode "MoveDown" },
    { key = "k",  mods = "NONE",  action = act.CopyMode "MoveUp" },
    { key = "l",  mods = "NONE",  action = act.CopyMode "MoveRight" },
    -- move word
    { key = "f",  mods = "ALT",   action = act.CopyMode "MoveForwardWord" },
    { key = "\t", mods = "NONE",  action = act.CopyMode "MoveForwardWord" },
    { key = "w",  mods = "NONE",  action = act.CopyMode "MoveForwardWord" },
    { key = "b",  mods = "ALT",   action = act.CopyMode "MoveBackwardWord" },
    { key = "\t", mods = "SHIFT", action = act.CopyMode "MoveBackwardWord" },
    { key = "b",  mods = "NONE",  action = act.CopyMode "MoveBackwardWord" },
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
    { key = "0",  mods = "NONE",  action = act.CopyMode "MoveToStartOfLine" },
    { key = "\n", mods = "NONE",  action = act.CopyMode "MoveToStartOfNextLine" },
    { key = "$",  mods = "SHIFT", action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "$",  mods = "NONE",  action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "e",  mods = "CTRL",  action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "m",  mods = "ALT",   action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "^",  mods = "SHIFT", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "^",  mods = "NONE",  action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "a",  mods = "CTRL",  action = act.CopyMode "MoveToStartOfLineContent" },

    -- select
    { key = " ",  mods = "NONE",  action = act.CopyMode { SetSelectionMode = "Cell" } },
    { key = "v",  mods = "NONE",  action = act.CopyMode { SetSelectionMode = "Cell" } },
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
          act.CopyMode "Close",
        },
      },
    },

    -- scroll
    { key = "G",        mods = "SHIFT", action = act.CopyMode "MoveToScrollbackBottom" },
    { key = "G",        mods = "NONE",  action = act.CopyMode "MoveToScrollbackBottom" },
    { key = "g",        mods = "NONE",  action = act.CopyMode "MoveToScrollbackTop" },
    { key = "H",        mods = "NONE",  action = act.CopyMode "MoveToViewportTop" },
    { key = "H",        mods = "SHIFT", action = act.CopyMode "MoveToViewportTop" },
    { key = "M",        mods = "NONE",  action = act.CopyMode "MoveToViewportMiddle" },
    { key = "M",        mods = "SHIFT", action = act.CopyMode "MoveToViewportMiddle" },
    { key = "L",        mods = "NONE",  action = act.CopyMode "MoveToViewportBottom" },
    { key = "L",        mods = "SHIFT", action = act.CopyMode "MoveToViewportBottom" },
    { key = "o",        mods = "NONE",  action = act.CopyMode "MoveToSelectionOtherEnd" },
    { key = "O",        mods = "NONE",  action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
    { key = "O",        mods = "SHIFT", action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
    { key = "PageUp",   mods = "NONE",  action = act.CopyMode "PageUp" },
    { key = "PageDown", mods = "NONE",  action = act.CopyMode "PageDown" },
    { key = "b",        mods = "CTRL",  action = act.CopyMode "PageUp" },
    { key = "f",        mods = "CTRL",  action = act.CopyMode "PageDown" },
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
    { key = "p",      mods = "CTRL", action = act.CopyMode "PriorMatch" },
    { key = "n",      mods = "CTRL", action = act.CopyMode "NextMatch" },
    { key = "r",      mods = "CTRL", action = act.CopyMode "CycleMatchType" },
    { key = "/",      mods = "NONE", action = act.CopyMode "ClearPattern" },
    { key = "u",      mods = "CTRL", action = act.CopyMode "ClearPattern" },
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
    mods = "CTRL",
    action = "OpenLinkAtMouseCursor",
  },
}

return {
  -- TODO: いつかtrueにする
  disable_default_key_bindings = false,
  leader = { key = "x", mods = "CTRL", timeout_milliseconds = 1000 },
  keys = utils.array_concat(default_keybinds, tmux_keybinds, wezterm_keybinds),
  key_tables = key_tables,
  mouse_bindings = mouse_bindings,
}
