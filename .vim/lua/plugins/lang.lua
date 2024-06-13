local ecma_scripts_ft = { "javascript", "javascriptreact", "jsx", "typescript", "typescriptreact", "tsx", "astro" }
local ruby_ft = { "ruby" }
local markdown_ft = { "markdown", "mkd" }

return {
  "editorconfig/editorconfig-vim",
  { "sam4llis/nvim-lua-gf", ft = { "lua" } },
  { "wavded/vim-stylus", ft = { "stylus" } },
  { "tpope/vim-rake", ft = ruby_ft },
  { "tpope/vim-rails", ft = ruby_ft },
  { "ap/vim-css-color", ft = table.insert({ "css" }, ecma_scripts_ft) },
  { "hotoo/jsgf.vim", ft = ecma_scripts_ft },
  { "tpope/vim-markdown", ft = markdown_ft },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = markdown_ft,
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}
