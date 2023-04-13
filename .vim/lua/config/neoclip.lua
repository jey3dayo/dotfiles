require("neoclip").setup {
  history = 500,
  enable_persistent_history = false,
  keys = {
    telescope = {
      i = {
        paste = "<CR>",
      },
      n = {
        paste = "<CR>",
      },
    },
  },
}

require("telescope").load_extension "neoclip"
