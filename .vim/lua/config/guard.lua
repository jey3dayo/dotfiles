local ft = require("guard.filetype")

-- ft("go"):fmt("gofmt")
-- ft("ruby"):fmt("rubocop"):lint "rubocop"
ft("sql,pgsql"):fmt("sql-formatter")
ft('typescript,javascript,typescriptreact,css,json,guard'):fmt('prettier')

-- Call setup() LAST!
require("guard").setup({
  -- the only options for the setup function
  fmt_on_save = true,

  -- Use lsp if no formatter was defined for this filetype
  lsp_as_default_formatter = false,
})
