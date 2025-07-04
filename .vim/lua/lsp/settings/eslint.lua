local utils = require "core.utils"
local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.eslint.config_files

return {
  init_options = {
    provideFormatter = false,  -- ESLintのフォーマット機能を無効化（lintに専念）
  },
  on_attach = function(client, bufnr)
    -- フォーマット機能を無効化（lint機能に専念）
    local compat = require("lsp.compat")
    if compat.supports_method(client, "textDocument/formatting") then
      client.server_capabilities.documentFormattingProvider = false
    end
    if compat.supports_method(client, "textDocument/rangeFormatting") then
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end,
  on_new_config = function(cfg, new_root)
    -- ESLint LSP 4.9.0以降のworkspaceFolder問題を修正
    cfg.settings = cfg.settings or {}
    cfg.settings.workspaceFolder = {
      uri = vim.uri_from_fname(new_root),
      name = vim.fn.fnamemodify(new_root, ':t'),
    }
  end,
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  autostart = function()
    local has_files = utils.has_config_files(config_files)
    if vim.g.lsp_debug then
      vim.notify(string.format("ESLint autostart check: %s (files: %s)", 
        tostring(has_files), table.concat(config_files, ", ")), vim.log.levels.DEBUG)
    end
    return has_files
  end,
}
