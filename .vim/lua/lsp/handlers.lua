local M = {}

local user_command = require("utils").user_command

local isDebug = true

local function notify_formatter(name)
  if isDebug then
    vim.notify("Formatted with: " .. name, vim.log.levels.INFO)
  end
end

-- フォーマットを実行する共通関数
local function format_buffer(bufnr, client)
  -- Disable with a global or buffer-local variable
  if vim.g.disable_autoformat then
    return nil
  end

  vim.lsp.buf.format {
    bufnr = bufnr,
    id = client.id,
    timeout_ms = 3000,
    -- async = true,
  }

  notify_formatter(client.name)
end

M.format_buffer = format_buffer

-- ドキュメントハイライト設定
M.lsp_highlight_document = function(client)
  local illuminate = safe_require "illuminate"
  if illuminate then
    illuminate.on_attach(client)
  end
end

-- フォーマッターのクライアント名を通知する関数
function M.notify_formatter_clients(bufnr)
  local active_clients = M.get_formatter_clients(bufnr)
  local client_names = vim.tbl_map(function(c)
    return c.name
  end, active_clients)

  notify_formatter(table.concat(client_names, ", "))
end

-- キーマップ設定
M.setup_lsp_keymaps = function(bufnr, client)
  local set_opts = { silent = true }
  Set_keymap("[lsp]", "<Nop>", set_opts)
  Set_keymap("<C-e>", "[lsp]", set_opts)

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  if client.supports_method "textDocument/formatting" then
    -- 複数回登録されてしまう
    Keymap("[lsp]f", function()
      -- TODO: 切り出す
      local clients = vim.lsp.get_clients { bufnr = bufnr }

      local active_clients = vim.tbl_filter(function(c)
        return c.supports_method "textDocument/formatting"
      end, clients)
      local client_names = vim.tbl_map(function(c)
        return c.name
      end, active_clients)

      vim.lsp.buf.format { async = true }

      notify_formatter(table.concat(client_names, ", "))
    end, bufopts)
  end

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

  -- workspace
  Keymap("<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  Keymap("<space>wa", function()
    print(vim.inspect(vim.lsp.buf.add_workspace_folder()))
  end, bufopts)
  Keymap("<space>wr", function()
    print(vim.inspect(vim.lsp.buf.remove_workspace_folder()))
  end, bufopts)
end

-- M.on_attach = function(client, bufnr) end
M.on_attach = function() end

local function setup_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
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

user_command("AutoFormatDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, { desc = "Disable autoformat-on-save", bang = true })

user_command("AutoFormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Re-enable autoformat-on-save" })

return M
