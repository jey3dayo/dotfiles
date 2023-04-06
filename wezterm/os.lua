local wezterm = require "wezterm"
local win = require "./win"

-- see https://wezfurlong.org/wezterm/config/lua/wezterm/target_triple.html for values
-- local is_linux = wezterm.target_triple == "x86_64-unknown-linux-gnu"
local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"

return is_windows and win or {}