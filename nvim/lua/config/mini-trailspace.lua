local M = {}

function M.setup()
  require("mini.trailspace").setup()
  vim.api.nvim_create_user_command("TrimWhitespace", function()
    require("mini.trailspace").trim()
    require("mini.trailspace").trim_last_lines()
  end, { desc = "Trim trailing whitespace" })
end

return M
