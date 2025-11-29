local utils = require "core.utils"
local with = utils.with
local config = require "lsp.config"
local client_utils = require "lsp.client_utils"

local M = {}

-- LSP keymaps using vim.keymap.set directly

-- Ensure mini.pick is loaded before mini.extra pickers to keep MiniPick global available
local function use_lsp_picker(scope, fallback)
  local pick_ok = pcall(require, "mini.pick")
  local extra_ok, mini_extra = pcall(require, "mini.extra")
  if pick_ok and extra_ok then
    mini_extra.pickers.lsp { scope = scope }
    return true
  end

  if fallback then fallback() end
  return false
end

local function jump_diagnostic(count)
  local jump = vim.diagnostic.jump
  if type(jump) == "function" then
    jump {
      count = count,
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float(bufnr, { scope = "cursor", focus = false })
      end,
    }
    return
  end

  -- Neovim 0.10 fallback
  local move = count > 0 and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  move()
  vim.diagnostic.open_float(0, { scope = "cursor", focus = false })
end

local function setup_workspace_keymaps(buf_opts)
  local workspace_mappings = {
    ["<space>wl"] = function()
      vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end,
    ["<space>wa"] = function()
      vim.notify(vim.inspect(vim.lsp.buf.add_workspace_folder()))
    end,
    ["<space>wr"] = function()
      vim.notify(vim.inspect(vim.lsp.buf.remove_workspace_folder()))
    end,
  }

  for key, func in pairs(workspace_mappings) do
    vim.keymap.set("n", key, func, buf_opts)
  end
end

local function setup_keymaps(client, bufnr)
  -- Ensure bufnr is a number
  bufnr = tonumber(bufnr) or vim.api.nvim_get_current_buf()
  local buf_opts = with(config.LSP.DEFAULT_BUF_OPTS, { buffer = bufnr })

  -- basic keymaps - Remove conflicting prefix mapping
  -- vim.keymap.set('n', config.LSP.PREFIX, "<Nop>", config.LSP.DEFAULT_OPTS)
  -- vim.keymap.set('n', "<C-e>", config.LSP.PREFIX, config.LSP.DEFAULT_OPTS)

  -- LSP keymaps (previously lspsaga)
  vim.keymap.set("n", "<C-j>", function()
    jump_diagnostic(1)
  end, buf_opts)
  vim.keymap.set("n", "<C-k>", function()
    jump_diagnostic(-1)
  end, buf_opts)
  vim.keymap.set("n", "<C-l>", vim.diagnostic.open_float, buf_opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, buf_opts)
  vim.keymap.set("n", "<C-[>", function()
    -- Get active LSP clients for current buffer
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    local has_references = false

    for _, active_client in ipairs(clients) do
      local compat = require "lsp.compat"
      if compat.supports_method(active_client, "textDocument/references") then
        has_references = true
        break
      end
    end

    if has_references or #clients > 0 then
      use_lsp_picker("references", function()
        vim.lsp.buf.references()
      end)
    else
      vim.notify("No LSP clients attached or references not supported", vim.log.levels.WARN)
    end
  end, buf_opts)
  vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, buf_opts)
  -- Direct LSP keymaps with <C-e> prefix (using vim.keymap.set for proper desc support)
  vim.keymap.set("n", "<C-e>a", vim.lsp.buf.code_action, with(buf_opts, { desc = "Code action" }))
  vim.keymap.set("n", "<C-e>d", vim.lsp.buf.declaration, with(buf_opts, { desc = "Declaration" }))
  vim.keymap.set("n", "<C-e>i", vim.lsp.buf.implementation, with(buf_opts, { desc = "Implementation" }))
  vim.keymap.set("n", "<C-e>t", vim.lsp.buf.type_definition, with(buf_opts, { desc = "Type definition" }))
  vim.keymap.set("n", "<C-e>k", vim.lsp.buf.definition, with(buf_opts, { desc = "Definition" }))
  vim.keymap.set("n", "<C-e>r", vim.lsp.buf.rename, with(buf_opts, { desc = "Rename" }))
  vim.keymap.set("n", "<C-e>o", function()
    -- Get active LSP clients for current buffer
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    local has_symbols = false

    for _, active_client in ipairs(clients) do
      local compat = require "lsp.compat"
      if compat.supports_method(active_client, "textDocument/documentSymbol") then
        has_symbols = true
        break
      end
    end

    if has_symbols or #clients > 0 then
      use_lsp_picker("document_symbol", function()
        vim.lsp.buf.document_symbol()
      end)
    else
      vim.notify("No LSP clients attached or document symbols not supported", vim.log.levels.WARN)
    end
  end, with(buf_opts, { desc = "Document symbols" }))

  setup_workspace_keymaps(buf_opts)

  -- LSP keymap descriptions are now set directly in vim.keymap.set calls above
end

local function setup_format_keymap(client, bufnr)
  -- 互換性レイヤーを使用した機能判定
  local compat = require "lsp.compat"
  if not compat.supports_method(client, "textDocument/formatting") then return end

  -- LSPフォーマット機能はkeymaps.luaのグローバルキーマップに移動
  -- ここでは互換性を保つが、重複するキーマップは設定しない
end

M.setup = function(client, bufnr)
  setup_keymaps(client, bufnr)
  setup_format_keymap(client, bufnr)
end

return M
