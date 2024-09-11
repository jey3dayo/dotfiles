vim.opt_local.wrap = false
vim.opt_local.tabstop = 2
vim.opt_local.textwidth = 0
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true


Keymap('[lsp]j', '<cmd>:!babel-node "%"<CR>')
Keymap('[lsp]J', '<cmd>:!jest "%"<CR>')
