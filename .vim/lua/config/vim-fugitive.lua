local utils = require "core.utils"
local gitlinker = utils.safe_require "gitlinker"
if not gitlinker then return end

-- Direct <C-g> keymaps without [git] prefix
vim.keymap.set("n", "<C-g><C-g>", "<cmd>DiffviewOpen<CR>", { desc = "DiffviewOpen" })

-- Git status (moved from ,G)  
vim.keymap.set("n", "<C-g>s", function()
  local ok, mini_extra = pcall(require, "mini.extra")
  if ok then
    mini_extra.pickers.git_files()
  else
    vim.cmd("Git")
  end
end, { desc = "Git status" })

vim.keymap.set("n", "<C-g>a", "<cmd>Git add %<CR>", { desc = "Git add current file" })
vim.keymap.set("n", "<C-g>b", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<C-g>d", "<cmd>Gdiffsplit<CR>", { desc = "Git diff split" })
vim.keymap.set("n", "<C-g>h", "<cmd>DiffviewFileHistory<CR>", { desc = "File history" })
vim.keymap.set("n", "<C-g>H", "<cmd>DiffviewFileHistory %<CR>", { desc = "Current file history" })
vim.keymap.set("n", "<C-g>e", "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus files" })
vim.keymap.set("n", "<C-g>r", "<cmd>DiffviewOpen<CR>", { desc = "Reopen diff" })
vim.keymap.set("n", "<C-g>g", "<cmd>Ggrep<Space>", { desc = "Git grep" })
vim.keymap.set("n", "<C-g>w", "<cmd>Gwrite<CR>", { desc = "Git write" })
vim.keymap.set("n", "<C-g>x", "<cmd>DiffviewClose<CR>", { desc = "Close diff" })
vim.keymap.set("n", "<C-g>y", '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".copy_to_clipboard})<cr>', { desc = "Copy git link" })
vim.keymap.set("n", "<C-g>Y", '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', { desc = "Open git link" })

vim.keymap.set("v", "<C-g>y", '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".copy_to_clipboard})<cr>', { desc = "Copy git link" })
vim.keymap.set("v", "<C-g>Y", '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', { desc = "Open git link" })
