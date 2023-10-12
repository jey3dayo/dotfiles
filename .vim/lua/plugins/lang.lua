local ecma_scripts_ft = { "javascript", "javascriptreact", "jsx", "typescript", "typescriptreact", "tsx", "astro" }
local ruby_ft = { "ruby" }

return {
  { "sam4llis/nvim-lua-gf", ft = { "lua" } },
  { "wavded/vim-stylus",    ft = { "stylus" } },
  { "tpope/vim-rake",       ft = ruby_ft },
  { "tpope/vim-rails",      ft = ruby_ft },
  { "tpope/vim-markdown",   ft = { "markdown", "mkd" } },
  { "ap/vim-css-color",     ft = table.insert({ "css" }, ecma_scripts_ft) },
  { "hotoo/jsgf.vim",       ft = ecma_scripts_ft },
}
