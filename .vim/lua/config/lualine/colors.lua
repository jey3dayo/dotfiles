local M = {}

-- Color table for highlights
M.colors = {
  bg = '#202328',
  fg = '#bbc2cf',
  yellow = '#ECBE7B',
  cyan = '#008080',
  darkblue = '#081633',
  green = '#98be65',
  orange = '#FF8800',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ec5f67'
}

M.colors.primary = M.colors.violet

-- Auto change color according to neovim mode
M.mode_color = {
  n = M.colors.primary,
  i = M.colors.green,
  v = M.colors.blue,
  ["\22"] = M.colors.blue,
  V = M.colors.blue,
  c = M.colors.magenta,
  no = M.colors.red,
  s = M.colors.orange,
  S = M.colors.orange,
  ["\19"] = M.colors.orange,
  ic = M.colors.yellow,
  R = M.colors.violet,
  Rv = M.colors.violet,
  cv = M.colors.red,
  ce = M.colors.red,
  r = M.colors.cyan,
  rm = M.colors.cyan,
  ["r?"] = M.colors.cyan,
  ["!"] = M.colors.red,
  t = M.colors.red,
}

return M