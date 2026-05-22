local wezterm = require "wezterm"

local act = wezterm.action

return {
  resize_pane = {
    { key = "h", action = act { AdjustPaneSize = { "Left", 1 } } },
    { key = "l", action = act { AdjustPaneSize = { "Right", 1 } } },
    { key = "k", action = act { AdjustPaneSize = { "Up", 1 } } },
    { key = "j", action = act { AdjustPaneSize = { "Down", 1 } } },
    { key = "+", action = act { EmitEvent = "increase-opacity" } },
    { key = "-", action = act { EmitEvent = "decrease-opacity" } },
    { key = "0", action = act { EmitEvent = "reset-opacity" } },
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
    { key = "h", mods = "NONE", action = act.CopyMode "MoveLeft" },
    { key = "j", mods = "NONE", action = act.CopyMode "MoveDown" },
    { key = "k", mods = "NONE", action = act.CopyMode "MoveUp" },
    { key = "l", mods = "NONE", action = act.CopyMode "MoveRight" },
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
    { key = "0", mods = "NONE", action = act.CopyMode "MoveToStartOfLine" },
    { key = "a", mods = "CTRL", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "^", mods = "SHIFT", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "^", mods = "NONE", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = "e", mods = "CTRL", action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "$", mods = "SHIFT", action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "$", mods = "NONE", action = act.CopyMode "MoveToEndOfLineContent" },
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
