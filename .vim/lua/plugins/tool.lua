return {
  {
    "tpope/vim-fugitive",
    cmd = { "Gdiffsplit", "Ggrep", "Gstatus", "Gwrite", "Gcommit" },
    config = function()
      require "config/vim-fugitive"
    end,
  },
  { "tpope/vim-rhubarb",       dependencies = { "tpope/vim-fugitive" } },
  { "vim-scripts/renamer.vim", cmd = "Renamer" },
  { "vim-scripts/sudo.vim",    cmd = { "SudoWrite", "SudoRead" } },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },
}
