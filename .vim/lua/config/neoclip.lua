require("neoclip").setup {
  history = 1000,
  enable_persistent_history = true,
  keys = {
    telescope = {
      i = {
        paste = "<CR>",
      },
      n = {
        delete = "d",
        edit = "e",
        paste = "<CR>",
      },
    },
  },
}

require("telescope").load_extension "neoclip"
