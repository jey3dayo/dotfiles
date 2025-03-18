return {
  chunk = {
    enable = true,
    notify = false,
    use_treesitter = true,
    chars = {
      horizontal_line = "─",
      vertical_line = "│",
      left_top = "╭",
      left_bottom = "╰",
      right_arrow = ">",
    },
    style = {
      { fg = "#a292a3" },
      { fg = "#c4746e" },
    },
    textobject = "",
    max_file_size = 1024 * 1024,
    error_sign = true,
    exclude_filetypes = {
      neotest_summary = true,
      ["neo-tree"] = true,
      dashboard = true,
      help = true,
      TelescopePrompt = true,
      NvimTree = true,
    },
  },
  indent = {
    enable = true,
    use_treesitter = false,
    chars = { "│" },
    style = { { fg = "#2A2A37" } },
    exclude_filetypes = {
      dashboard = true,
      help = true,
      TelescopePrompt = true,
      NvimTree = true,
    },
  },
  line_num = { enable = false },
  blank = {
    enable = false,
    chars = { " " },
    style = { { bg = "#2A2A37" }, { bg = "", fg = "" } },
  },
}
