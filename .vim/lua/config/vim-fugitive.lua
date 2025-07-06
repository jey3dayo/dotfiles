local utils = require "core.utils"
local gitlinker = utils.safe_require "gitlinker"
if not gitlinker then return end

-- Direct <C-g> keymaps without [git] prefix
Keymap("<C-g><C-g>", "<cmd>DiffviewOpen<CR>", { desc = "DiffviewOpen" })

-- Git status (moved from ,G)  
Keymap("<C-g>s", function()
  require("telescope.builtin").git_status()
end, { desc = "Git status" })

Keymap("<C-g>a", "<cmd>Git add %<CR>", { desc = "Git add current file" })
Keymap("<C-g>b", "<cmd>Git blame<CR>", { desc = "Git blame" })
Keymap("<C-g>d", "<cmd>Gdiffsplit<CR>", { desc = "Git diff split" })
Keymap("<C-g>h", "<cmd>DiffviewFileHistory<CR>", { desc = "File history" })
Keymap("<C-g>H", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current file history" })
Keymap("<C-g>e", "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus files" })
Keymap("<C-g>r", "<cmd>DiffviewOpen<CR>", { desc = "Reopen diff" })
Keymap("<C-g>g", "<cmd>Ggrep<Space>", { desc = "Git grep" })
Keymap("<C-g>w", "<cmd>Gwrite<CR>", { desc = "Git write" })
Keymap("<C-g>x", "<cmd>DiffviewClose<CR>", { desc = "Close diff" })
Keymap(
  "<C-g>y",
  '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".copy_to_clipboard})<cr>',
  { desc = "Copy git link" }
)
Keymap(
  "<C-g>Y",
  '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
  { desc = "Open git link" }
)

V_Keymap(
  "<C-g>y",
  '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".copy_to_clipboard})<cr>',
  { desc = "Copy git link" }
)
V_Keymap(
  "<C-g>Y",
  '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>',
  { desc = "Open git link" }
)
