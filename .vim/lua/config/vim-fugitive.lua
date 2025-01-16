local gitlinker = Safe_require "gitlinker"
if not gitlinker then return end

local set_opts = { silent = true }
Set_keymap("[git]", "<Nop>", set_opts)
Set_keymap("<C-g>", "[git]", set_opts)

Keymap("[git]<C-g>", "<cmd>DiffviewOpen<CR>")

Keymap("[git]b", "<cmd>Git blame<CR>")
Keymap("[git]d", "<cmd>Gdiffsplit<CR>")
Keymap("[git]h", "<cmd>DiffviewFileHistory<CR>")
Keymap("[git]H", "<cmd>DiffviewFileHistory %<CR>")
Keymap("[git]e", "<cmd>DiffviewFocusFiles<CR>")
Keymap("[git]r", "<cmd>DiffviewRefresh<CR>")
Keymap("[git]g", "<cmd>Ggrep<Space>")
Keymap("[git]w", "<cmd>Gwrite<CR>")
Keymap("[git]x", "<cmd>DiffviewClose<CR>")
Keymap(
  "[git]y",
  '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".copy_to_clipboard})<cr>'
)
Keymap(
  "[git]Y",
  '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>'
)

V_Keymap(
  "[git]y",
  '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".copy_to_clipboard})<cr>'
)
V_Keymap(
  "[git]Y",
  '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>'
)
