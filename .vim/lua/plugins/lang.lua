return {
  { "sam4llis/nvim-lua-gf", ft = { "lua" } },
  { "wavded/vim-stylus", ft = { "stylus" } },
  { "tpope/vim-rake", ft = { "ruby" } },
  { "tpope/vim-rails", ft = { "ruby" } },
  { "tpope/vim-markdown", ft = { "markdown", "mkd" } },
  { "vito-c/jq.vim", ft = { "jq" } },
  { "ap/vim-css-color", ft = { "css", "javascript", "javascript.jsx", "jsx" } },
  { "hotoo/jsgf.vim", ft = { "typescript", "typescript.tsx", "tsx" } },
  { "MunifTanjim/prettier.nvim",
    config = function()
      require("config/prettier")
    end,
  },
}
