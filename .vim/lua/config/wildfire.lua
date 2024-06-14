-- " This selects the next closest text object.
Keymap("<Space>", "<Plug>(wildfire-fuel)")

-- " This selects the previous closest text object.
V_Keymap("<C-Space>", "<Plug>(wildfire-water)")

vim.g.wildfire_objects = {
  { "iw", "i`", "a`", "i'", "a'", 'i"', 'a"', "i|", "i)", "i]", "i}", "ip", "it", "at", "i>" },
}
