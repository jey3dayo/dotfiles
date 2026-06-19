local M = {}

local function zoom()
  require("mini.misc").zoom(0, {})
end

function M.setup()
  require("mini.misc").setup()
  require("mini.misc").setup_restore_cursor()

  vim.api.nvim_create_user_command("Zoom", zoom, { desc = "Toggle window zoom" })
  vim.keymap.set("n", "<leader>z", zoom, { desc = "Toggle window zoom" })
end

return M
