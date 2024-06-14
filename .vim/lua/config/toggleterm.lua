Keymap("<Leader>T", "<cmd>ToggleTerm<CR>")
I_Keymap("<Leader>T", "<cmd>ToggleTerm<CR>")

-- vim.api.nvim_set_keymap("t", "<Esc>", "<C-\\><C-n>", { noremap = true })
T_Keymap("<Esc>", "<C-\\><C-n>", { noremap = true })

return {
  open_mapping = [[<c-\>]],
  insert_mappings = true,
  terminal_mappings = true,
}
