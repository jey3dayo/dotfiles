local M = {}

function M.setup()
  local substitute = require "substitute"
  local undo_glow = require "undo-glow"

  substitute.setup {
    on_substitute = function(event)
      undo_glow.highlight_on_substitute(event)
    end,
  }

  vim.keymap.set("n", "cx", substitute.operator, { desc = "Substitute operator" })
  vim.keymap.set("n", "cxx", substitute.line, { desc = "Substitute line" })
  vim.keymap.set("n", "cX", substitute.eol, { desc = "Substitute to end of line" })
  vim.keymap.set("x", "cx", substitute.visual, { desc = "Substitute visual" })
end

return M
