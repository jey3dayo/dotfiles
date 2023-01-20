local status, prettier = pcall(require, "prettier")
if (not status) then return end

prettier.setup {
  bin = "prettierd",
  filetypes = {
    "css",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "scss",
    "less"
  }
}

local set_opts = { noremap = true, silent = false }
vim.api.nvim_set_keymap("n", "[lsp]p", ":<C-u>Prettier<CR>", set_opts)
