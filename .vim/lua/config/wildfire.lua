return {
  surrounds = { { "(", ")" }, { "{", "}" }, { "<", ">" }, { "[", "]" } },
  keymaps = {
    init_selection = "<CR>",
    node_incremental = "<CR>",
    node_decremental = "<BS>",
  },
  filetype_exclude = { "qf" }, -- keymaps will be unset in excluding filetypes
}
