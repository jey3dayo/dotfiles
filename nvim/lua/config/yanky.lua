local M = {}

function M.opts()
  local is_wsl = require("core.utils").get_os() == "wsl"

  return {
    ring = {
      history_length = 100,
      storage = "sqlite",
      sync_with_numbered_registers = true,
      cancel_event = "update",
    },
    picker = { select = { action = nil } },
    system_clipboard = { sync_with_ring = not is_wsl },
    highlight = {
      on_put = true,
      on_yank = false,
      timer = 300,
    },
    preserve_cursor_position = { enabled = true },
  }
end

function M.keys()
  return {
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank" },
    { "Y", "<Plug>(YankyYank)$", mode = { "n" }, desc = "Yank to EOL" },
    {
      "<leader>p",
      function()
        require("yanky").put("p", true)
      end,
      desc = "Put with yanky",
    },
    {
      "<leader>P",
      function()
        require("yanky").put("P", true)
      end,
      desc = "Put before with yanky",
    },
    { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
    { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
    { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after with filter" },
    { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before with filter" },
  }
end

return M
