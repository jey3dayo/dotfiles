local gitlinker = safe_require "gitlinker"
if not gitlinker then
  return
end

local set_opts = { silent = true }
Set_keymap("[git]", "<Nop>", set_opts)
Set_keymap("<C-g>", "[git]", set_opts)

Keymap("[git]b", "<cmd>Git blame<CR>")
Keymap("[git]d", "<cmd>DiffviewOpen<CR>")
Keymap("[git]h", "<cmd>DiffviewFileHistory<CR>")
Keymap("[git]H", "<cmd>DiffviewFileHistory %<CR>")
Keymap("[git]D", "<cmd>Gdiffsplit<CR>")
Keymap("[git]e", "<cmd>DiffviewFocusFiles<CR>")
Keymap("[git]r", "<cmd>DiffviewRefresh<CR>")
Keymap("[git]g", "<cmd>Ggrep<Space>")
Keymap("[git]s", "<cmd>Git status<CR>")
Keymap("[git]w", "<cmd>Gwrite<CR>")
Keymap("[git]x", "<cmd>DiffviewClose<CR>")
