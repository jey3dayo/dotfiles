local prettier = safe_require "prettier"

if not prettier then
  return
end

prettier.setup {
  filetypes = {
    "css",
    "graphql",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "less",
    "scss",
    "typescript",
    "typescriptreact",
    "yaml",
    "markdown",
    "svelte",
  },
}

local set_opts = { noremap = true, silent = false }
Keymap("[lsp]p", "<cmd>Prettier<CR>", set_opts)
