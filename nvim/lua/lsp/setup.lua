-- Single entry point for LSP activation. `vim.lsp.enable` must not be
-- called anywhere else.
local config = require "lsp.config"
local handlers = require "lsp.handlers"

vim.lsp.config("*", {
  capabilities = require("lsp.capabilities").setup(),
  handlers = handlers.handlers,
})

-- on_attach is NOT set here: attach-time buffer setup (keymaps, diagnostics,
-- omnifunc, formatter/highlight lazy-load) is consolidated into the single
-- LspAttach autocmd in lua/autocmds.lua (augroup LspFormatting). A second
-- LspAttach registration here would run keymaps.setup and friends twice per
-- attach.

vim.lsp.enable(config.servers)
