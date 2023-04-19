return {
  "tomtom/tcomment_vim",
  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign" },
    config = function()
      require "config/vim-easy-align"
    end,
  },
  {
    "nishigori/increment-activator",
    config = function()
      require "config/increment-activator-config"
    end,
  },
  "windwp/nvim-ts-autotag",
}
