local M = {}

local augroup = require("autocmds").augroup
local user_command = require("utils").user_command
local autocmd = require("autocmds").autocmd
local clear_autocmds = require("autocmds").clear_autocmds

local lspFormatting = augroup("LspFormatting", { clear = true })

-- フォーマットを実行する共通関数
local function format_buffer(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }

  -- フォーマット可能なクライアントをフィルタリング
  local active_clients = vim.tbl_filter(function(client)
    return client.supports_method "textDocument/formatting"
  end, clients)

  if #active_clients == 0 then
    vim.notify("No LSP client supports formatting", vim.log.levels.WARN)
    return false
  end

  vim.lsp.buf.format {
    bufnr = bufnr,
    timeout_ms = 3000,
    async = false,
  }

  -- フォーマットに使用したクライアント名を通知
  local client_names = vim.tbl_map(function(client)
    return client.name
  end, active_clients)
  vim.notify("Formatted with: " .. table.concat(client_names, ", "), vim.log.levels.INFO)

  return true
end

-- ドキュメントハイライト設定
local function lsp_highlight_document(client)
  local illuminate = safe_require "illuminate"
  if illuminate then
    illuminate.on_attach(client)
  end
end

-- キーマップ設定
local function setup_lsp_keymaps(bufnr)
  local set_opts = { silent = true }
  Set_keymap("[lsp]", "<Nop>", set_opts)
  Set_keymap("<C-e>", "[lsp]", set_opts)

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  Keymap("[lsp]f", function()
    format_buffer(bufnr)
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

M.setup_lsp_keymaps = setup_lsp_keymaps

M.on_attach = function(client, bufnr)
  setup_lsp_keymaps(bufnr)
  lsp_highlight_document(client)

  if client.supports_method "textDocument/formatting" then
    clear_autocmds { group = lspFormatting, buffer = bufnr }
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

-- 自動フォーマット設定
vim.g.disable_autoformat = false

autocmd("BufWritePost", {
  group = lspFormatting,
  callback = function(ev)
    local bufnr = ev.buf

    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return nil
    end

    format_buffer(bufnr)
  end,
})

user_command("AutoFormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

user_command("AutoFormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

return M
