return {
  {
    "h1mesuke/vim-alignta",
    cmd = { "Align", "Alignta" },
    config = function()
      vim.cmd [[ source ~/.config/nvim/plugins/vim-alignta.rc.vim ]]
    end,
  },
  {
    "tomtom/tcomment_vim",
  },
  {
    "nishigori/increment-activator",
    config = function()
      vim.cmd [[ source ~/.config/nvim/plugins/increment-activator.rc.vim ]]
    end,
  },
}
