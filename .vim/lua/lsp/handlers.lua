local M = {}

local augroup = require("autocmds").augroup

local lspFormatting = augroup("LspFormatting", { clear = true })

local function lsp_highlight_document(client)
  local illuminate = safe_require "illuminate"
  if not illuminate then
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
  Keymap("<C-l>", "<cmd>Lspsaga show_line_diagnostics<CR>", bufopts)
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

-- fomatter用のconfigファイルが存在するか確認する
local lsp_config_files = require("lsp.config").config_files
M.is_exist_config_files = function(formatter_name)
  local config_files = lsp_config_files[formatter_name]
  if not config_files then
    return false
  end

  local is_exist_file = false
  for _, file in ipairs(config_files) do
    if vim.fn.filereadable(file) == 1 then
      is_exist_file = true
    end
  end
  return is_exist_file
end

return M
