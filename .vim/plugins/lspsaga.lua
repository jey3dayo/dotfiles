local keymap = vim.keymap.set
local status, saga = pcall(require, 'lspsaga')
if (not status) then return end

saga.init_lsp_saga {
  server_filetype_map = {
    typescript = 'typescript'
  }
}

local opts = { noremap = true, silent = true }
keymap('n', '<C-j>', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)
keymap('n', '<C-k>', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', opts)
-- keymap('i', '<C-k>', '<Cmd>Lspsaga signature_help<CR>', opts)
keymap('n', '<C-[>', '<Cmd>Lspsaga lsp_finder<CR>', opts)
keymap('n', '[lsp]r', '<cmd>Lspsaga rename<CR>', opts)
keymap('n', '[lsp]a', '<cmd>Lspsaga code_action<CR>', opts)
