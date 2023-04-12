local set_opts = { noremap = true }

vim.api.nvim_set_keymap("n", "[fugitive]", "<Nop>", {})
vim.api.nvim_set_keymap("n", "<C-g>", "[fugitive]", {})
vim.api.nvim_set_keymap("n", "[fugitive]b", ":Git blame<CR>", set_opts)
vim.api.nvim_set_keymap("n", "[fugitive]d", ":Gdiffsplit<CR>", set_opts)
vim.api.nvim_set_keymap("n", "[fugitive]D", ":Git diff<CR>", set_opts)
vim.api.nvim_set_keymap("n", "[fugitive]g", ":Ggrep<Space>", set_opts)
vim.api.nvim_set_keymap("n", "[fugitive]s", ":Git status<CR>", set_opts)
vim.api.nvim_set_keymap("n", "[fugitive]w", ":Gwrite<CR>", set_opts)
vim.api.nvim_set_keymap("n", "[fugitive]c", ":Gcommit<CR>", set_opts)
