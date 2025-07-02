local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.ts_ls.config_files

return {
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
    tsserver = {
      useSyntaxServer = "never",
    },
  },
  on_attach = function(client, bufnr)
    -- テスト: server_capabilities変更を一時的に無効化
    -- if client.server_capabilities.documentFormattingProvider then
    --   client.server_capabilities.documentFormattingProvider = false
    -- end
    -- if client.server_capabilities.documentRangeFormattingProvider then
    --   client.server_capabilities.documentRangeFormattingProvider = false
    -- end
    vim.notify(string.format("[LSP] ts_ls attached successfully (id=%d, capabilities unchanged)", client.id), vim.log.levels.DEBUG)
  end,
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
}
