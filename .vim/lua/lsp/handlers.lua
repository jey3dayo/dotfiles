local M = {}

local augroup = require("autocmds").augroup

local lspFormatting = augroup("LspFormatting", { clear = true })

local function lsp_highlight_document(client)
  local illuminate = safe_require "illuminate"
  if illuminate then
    illuminate.on_attach(client)
  end
end

local function setup_lsp_keymaps(bufnr)
  local set_opts = { silent = true }
  Set_keymap("[lsp]", "<Nop>", set_opts)
  Set_keymap("<C-e>", "[lsp]", set_opts)

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  Keymap("[lsp]f", function()
    vim.lsp.buf.format()
    vim.notify("Formatting completed", vim.log.levels.INFO)
  end, bufopts)

  Keymap("[lsp]F", function()
    local clients = vim.lsp.get_active_clients { bufnr = bufnr }
    for _, client in ipairs(clients) do
      if client.supports_method "textDocument/formatting" then
        vim.lsp.buf.format { bufnr = bufnr }
        vim.notify("Formatted with " .. client.name, vim.log.levels.INFO)
        return
      end
    end
    vim.notify("No LSP client supports formatting", vim.log.levels.WARN)
  end, bufopts)

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
  Keymap("[lsp]K", "<cmd>Lspsaga peek_definition<CR>", bufopts)
  Keymap("[lsp]r", "<cmd>Lspsaga rename<CR>", bufopts)
  Keymap("[lsp]o", "<cmd>Lspsaga outline<CR>", bufopts)
end

M.on_attach = function(client, bufnr)
  setup_lsp_keymaps(bufnr)
  lsp_highlight_document(client)

  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = lspFormatting, buffer = bufnr }
  end
end

local function setup_capabilities()
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
  return capabilities
end

M.capabilities = setup_capabilities()

-- formatter用のconfigファイルが存在するか確認する
function M.is_exist_config_files(formatter_name)
  local config_files = require("lsp.config").config_files[formatter_name]
  if not config_files then
    return false
  end

  for _, file in ipairs(config_files) do
    if vim.fn.filereadable(file) == 1 then
      return true
    end
  end
  return false
end

return M
