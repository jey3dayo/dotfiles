local utils = require "core.utils"
local with = utils.with
local config = require "lsp.config"
local client_manager = require "lsp.client_manager"

local M = {}

local function setup_lspsaga_keymaps(buf_opts)
  local lspsaga_mappings = {
    ["<C-j>"] = "diagnostic_jump_next",
    ["<C-k>"] = "diagnostic_jump_prev",
    ["<C-l>"] = "show_line_diagnostics",
    ["K"] = "hover_doc",
    ["<C-[>"] = "finder",
    ["<C-]>"] = "goto_definition",
    [config.LSP.PREFIX .. "a"] = "code_action",
    [config.LSP.PREFIX .. "t"] = "goto_type_definition",
    [config.LSP.PREFIX .. "k"] = "peek_definition",
    [config.LSP.PREFIX .. "r"] = "rename",
    [config.LSP.PREFIX .. "o"] = "outline",
  }

  for key, cmd in pairs(lspsaga_mappings) do
    Keymap(key, "<cmd>Lspsaga " .. cmd .. "<CR>", buf_opts)
  end
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
    Keymap(key, func, buf_opts)
  end
end

local function setup_keymaps(bufnr, _)
  local buf_opts = with(config.LSP.DEFAULT_BUF_OPTS, { buffer = bufnr })

  -- basic keymaps
  Set_keymap(config.LSP.PREFIX, "<Nop>", config.LSP.DEFAULT_OPTS)
  Set_keymap("<C-e>", config.LSP.PREFIX, config.LSP.DEFAULT_OPTS)
  Keymap(config.LSP.PREFIX .. "d", vim.lsp.buf.declaration, buf_opts)
  Keymap(config.LSP.PREFIX .. "i", vim.lsp.buf.implementation, buf_opts)

  setup_lspsaga_keymaps(buf_opts)
  setup_workspace_keymaps(buf_opts)
end

local function setup_format_keymap(bufnr, client)
  if not client.supports_method "textDocument/formatting" then return end

  Keymap(config.LSP.PREFIX .. "f", function()
    local active_clients = client_manager.get_format_clients(bufnr)
    local client_names = vim.tbl_map(function(c)
      return c.name
    end, active_clients)

    vim.lsp.buf.format { async = true, timeout_ms = 5000 }

    require("lsp/formatter").notify_formatter(table.concat(client_names, ", "))
  end, with(config.LSP.DEFAULT_BUF_OPTS, { buffer = bufnr }))
end

M.setup = function(bufnr, client)
  setup_keymaps(bufnr, client)
  setup_format_keymap(bufnr, client)
end

return M
