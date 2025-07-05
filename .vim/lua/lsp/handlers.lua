-- LSP handlers configuration
local M = {}

M.setup = function()
  -- IMPORTANT: We don't need to override client/registerCapability
  -- because Neovim 0.11.x already has a built-in handler for it.
  -- The MethodNotFound error was caused by noice.nvim overwriting
  -- the entire vim.lsp.handlers table.

  -- If you need to customize other handlers, do it like this:
  -- local handlers = vim.lsp.handlers
  -- handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, {
  --   border = "rounded",
  -- })
end

return M

