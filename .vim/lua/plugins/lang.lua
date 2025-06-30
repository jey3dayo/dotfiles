local ft = require "core.filetypes"

return {
  { "editorconfig/editorconfig-vim", event = { "BufReadPre", "BufNewFile" } },
  { "sam4llis/nvim-lua-gf", ft = { "lua" } },
  { "wavded/vim-stylus", ft = { "stylus" } },
  { "tpope/vim-rake", ft = ft.ruby },
  { "tpope/vim-rails", ft = ft.ruby },
  { "ap/vim-css-color", ft = vim.list_extend({ "css" }, ft.ecma_scripts) },
  { "hotoo/jsgf.vim", ft = ft.ecma_scripts },
  { "tpope/vim-markdown", ft = ft.markdown },
  { "prisma/vim-prisma", ft = { "prisma" } },
  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop",
    },
    ft = ft.markdown,
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}
