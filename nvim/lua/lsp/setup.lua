-- Single entry point for LSP activation. `vim.lsp.enable` must not be
-- called anywhere else.
local config = require "lsp.config"
local handlers = require "lsp.handlers"

vim.lsp.config("*", {
  capabilities = require("lsp.capabilities").setup(),
  handlers = handlers.handlers,
})

-- on_attach is not set here: attach-time setup lives in the single LspAttach
-- autocmd in lua/autocmds.lua. A second registration would run it twice.

vim.lsp.enable(config.servers)
