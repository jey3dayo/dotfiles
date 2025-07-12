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
    -- Disable verbose logging at server level
    client.config.settings = client.config.settings or {}
    client.config.settings.typescript = client.config.settings.typescript or {}
    client.config.settings.typescript.preferences = client.config.settings.typescript.preferences or {}
    client.config.settings.typescript.preferences.disableTypeScriptVersions = true
  end,
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
}
