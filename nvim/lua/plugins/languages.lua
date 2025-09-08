local ft = require "core.filetypes"

return {
  { "sam4llis/nvim-lua-gf", ft = { "lua" } },
  { "tpope/vim-rake", ft = ft.ruby },
  { "tpope/vim-rails", ft = ft.ruby },
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
