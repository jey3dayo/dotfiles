-- LSP handlers configuration
local M = {}

M.setup = function()
  -- IMPORTANT: We don't need to override client/registerCapability
  -- because Neovim 0.11.x already has a built-in handler for it.
  -- The MethodNotFound error was resolved by switching to vscode-json-languageserver@1.3.4
  -- instead of vscode-langservers-extracted which had compatibility issues.

  -- If you need to customize other handlers, do it like this:
  -- local handlers = vim.lsp.handlers
  -- handlers["textDocument/hover"] = vim.lsp.with(handlers.hover, {
  --   border = "rounded",
  -- })
end

return M

