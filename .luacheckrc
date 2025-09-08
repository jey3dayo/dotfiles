globals = {
  "vim",
  "Safe_require",
  "Keymap",
  "I_Keymap",
  "V_Keymap",
  "X_Keymap",
  "O_Keymap",
  "T_Keymap",
  "Set_keymap",
  "Buf_set_keymap",
  "autocmd",
  "augroup",
  "user_command",
}

exclude_files = {
  ".luarocks/**",
}

-- Suppress warnings for unused arguments and variables in Neovim config
ignore = {
  "211", -- Unused local variable
  "212", -- Unused argument
  "213", -- Unused loop variable
  "311", -- Value assigned to a local variable is unused
  "431", -- Shadowing upvalue
}

max_line_length = false
