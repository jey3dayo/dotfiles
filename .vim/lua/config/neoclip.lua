require("neoclip").setup {
  history = 1000,
  enable_persistent_history = true,
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
