local M = {}

local augroup = require("autocmds").augroup

local lspFormatting = augroup("LspFormatting", { clear = true })

local function lsp_highlight_document(client)
  local status, illuminate = pcall(require, "illuminate")
  if not status then
    return
  end
  illuminate.on_attach(client)
end

local lsp_keymaps = function(bufnr)
  local set_opts = { silent = true }
  Set_keymap("[lsp]", "<Nop>", set_opts)
  Set_keymap("<C-e>", "[lsp]", set_opts)

  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  Keymap("[lsp]f", vim.lsp.buf.format, bufopts)
  Keymap("[lsp]d", vim.lsp.buf.declaration, bufopts)
  Keymap("[lsp]i", vim.lsp.buf.implementation, bufopts)

  -- lspsaga
  Keymap("<C-j>", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)
  Keymap("<C-k>", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
  Keymap("K", "<cmd>Lspsaga hover_doc<CR>", bufopts)
  Keymap("<C-[>", "<cmd>Lspsaga finder<CR>", bufopts)
  Keymap("<C-]>", "<cmd>Lspsaga goto_definition<CR>", bufopts)
  Keymap("[lsp]a", "<cmd>Lspsaga code_action<CR>", bufopts)
  Keymap("[lsp]t", "<cmd>Lspsaga goto_type_definition<CR>", bufopts)
  Keymap("[lsp]r", "<cmd>Lspsaga rename<CR>", bufopts)
  Keymap("[lsp]o", "<cmd>Lspsaga outline<CR>", bufopts)
end

M.on_attach = function(client, bufnr)
  lsp_keymaps(bufnr)
  lsp_highlight_document(client)

  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = lspFormatting, buffer = bufnr }
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    "documentation",
    "detail",
    "additionalTextEdits",
  },
}
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
M.capabilities = capabilities

return M
