local status, prettier = pcall(require, "prettier")
if (not status) then return end

prettier.setup {
  bin = "prettierd",
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
  }
}

local set_opts = { noremap = true, silent = false }
Keymap("[lsp]p", ":<C-u>Prettier<CR>")
