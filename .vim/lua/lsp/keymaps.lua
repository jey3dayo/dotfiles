local utils = require "core.utils"
local with = utils.with
local config = require "lsp.config"
local client_manager = require "lsp.client_manager"

local M = {}


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
    Keymap(key, func, buf_opts)
  end
end

local function setup_keymaps(client, bufnr)
  -- Ensure bufnr is a number
  bufnr = tonumber(bufnr) or vim.api.nvim_get_current_buf()
  local buf_opts = with(config.LSP.DEFAULT_BUF_OPTS, { buffer = bufnr })

  -- basic keymaps
  vim.keymap.set('n', config.LSP.PREFIX, "<Nop>", config.LSP.DEFAULT_OPTS)
  vim.keymap.set('n', "<C-e>", config.LSP.PREFIX, config.LSP.DEFAULT_OPTS)
  
  -- LSP keymaps (previously lspsaga)
  Keymap("<C-j>", vim.diagnostic.goto_next, buf_opts)
  Keymap("<C-k>", vim.diagnostic.goto_prev, buf_opts)
  Keymap("<C-l>", vim.diagnostic.open_float, buf_opts)
  Keymap("K", vim.lsp.buf.hover, buf_opts)
  Keymap("<C-[>", function() 
    local compat = require("lsp.compat")
    if compat.supports_method(client, "textDocument/references") then
      require('telescope.builtin').lsp_references()
    else
      vim.notify("LSP server does not support references", vim.log.levels.WARN)
    end
  end, buf_opts)
  Keymap("<C-]>", vim.lsp.buf.definition, buf_opts)
  Keymap(config.LSP.PREFIX .. "a", vim.lsp.buf.code_action, buf_opts)
  Keymap(config.LSP.PREFIX .. "d", vim.lsp.buf.declaration, buf_opts)
  Keymap(config.LSP.PREFIX .. "i", vim.lsp.buf.implementation, buf_opts)
  Keymap(config.LSP.PREFIX .. "t", vim.lsp.buf.type_definition, buf_opts)
  Keymap(config.LSP.PREFIX .. "k", vim.lsp.buf.definition, buf_opts)
  Keymap(config.LSP.PREFIX .. "r", vim.lsp.buf.rename, buf_opts)
  Keymap(config.LSP.PREFIX .. "o", function() 
    local compat = require("lsp.compat")
    if compat.supports_method(client, "textDocument/documentSymbol") then
      require('telescope.builtin').lsp_document_symbols()
    else
      vim.notify("LSP server does not support document symbols", vim.log.levels.WARN)
    end
  end, buf_opts)

  setup_workspace_keymaps(buf_opts)
end

local function setup_format_keymap(client, bufnr)
  -- 互換性レイヤーを使用した機能判定
  local compat = require("lsp.compat")
  if not compat.supports_method(client, "textDocument/formatting") then
    return
  end

  -- LSPフォーマット機能はkeymaps.luaのグローバルキーマップに移動
  -- ここでは互換性を保つが、重複するキーマップは設定しない
end

M.setup = function(client, bufnr)
  setup_keymaps(client, bufnr)
  setup_format_keymap(client, bufnr)
end

return M
