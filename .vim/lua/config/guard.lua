local ft = require("guard.filetype")

-- ft("go"):fmt("gofmt")
-- ft("ruby"):fmt("rubocop"):lint "rubocop"
-- ft('lua'):fmt('lsp'):append('stylua')
ft("sql,pgsql"):fmt("sql-formatter")

ft('typescript,javascript,typescriptreact,css,json,astro'):fmt('prettier')
ft('c,proto'):fmt('clang-format')

-- Call setup() LAST!
require("guard").setup({
  -- the only options for the setup function
  fmt_on_save = true,

  -- Use lsp if no formatter was defined for this filetype
  lsp_as_default_formatter = false,
})
