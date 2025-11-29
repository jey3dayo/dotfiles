-- Direct <C-g> keymaps without [git] prefix
vim.keymap.set("n", "<C-g><C-g>", "<cmd>DiffviewOpen<CR>", { desc = "DiffviewOpen" })

-- Git status (moved from ,G)
vim.keymap.set("n", "<C-g>s", function()
  local pick_ok = pcall(require, "mini.pick")
  local extra_ok, mini_extra = pcall(require, "mini.extra")
  if pick_ok and extra_ok then
    mini_extra.pickers.git_files()
  else
    vim.cmd "Git"
  end
end, { desc = "Git status" })

vim.keymap.set("n", "<C-g>b", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<C-g>d", "<cmd>Gdiffsplit<CR>", { desc = "Git diff split (current file)" })
vim.keymap.set("n", "<C-g>D", "<cmd>DiffviewOpen<CR>", { desc = "Diffview open (全体)" })
-- Hunk operations - <C-g>h as main entry point
vim.keymap.set("n", "<C-g>h", function()
  local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
  if not gitsigns_ok then
    vim.notify("GitSigns not loaded", vim.log.levels.WARN)
    return
  end

  -- Check if GitSigns is attached to current buffer
  if not gitsigns.get_hunks() or #gitsigns.get_hunks() == 0 then
    vim.notify("No hunks found in current buffer", vim.log.levels.INFO)
    return
  end

  gitsigns.stage_hunk()
end, { desc = "Stage current hunk" })

vim.keymap.set("n", "<C-g>r", function()
  local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
  if not gitsigns_ok then
    vim.notify("GitSigns not loaded", vim.log.levels.WARN)
    return
  end

  -- Check if GitSigns is attached to current buffer
  if not gitsigns.get_hunks() or #gitsigns.get_hunks() == 0 then
    vim.notify("No hunks found in current buffer", vim.log.levels.INFO)
    return
  end

  gitsigns.reset_hunk()
end, { desc = "Reset current hunk" })
vim.keymap.set("n", "<C-g>x", "<cmd>DiffviewClose<CR>", { desc = "Close diff" })

-- Hunk navigation (n/p pattern like vim search)
vim.keymap.set("n", "<C-g>n", function()
  local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
  if not gitsigns_ok then
    vim.notify("GitSigns not loaded", vim.log.levels.WARN)
    return
  end
  gitsigns.next_hunk()
end, { desc = "Next hunk" })

vim.keymap.set("n", "<C-g>p", function()
  local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
  if not gitsigns_ok then
    vim.notify("GitSigns not loaded", vim.log.levels.WARN)
    return
  end
  gitsigns.prev_hunk()
end, { desc = "Previous hunk" })
