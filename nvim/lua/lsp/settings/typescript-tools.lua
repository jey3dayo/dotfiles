local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local capabilities = require("lsp.capabilities").setup()
local handlers = require "lsp.handlers"

local function resolve_tsserver_path()
  return lsp_utils.get_mason_package_path("typescript-language-server", "node_modules/typescript/lib/tsserver.js")
end

local config_files = lsp_config.formatters["typescript-tools"].config_files
local tsserver_path = resolve_tsserver_path()

return {
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  capabilities = capabilities,
  handlers = handlers.handlers,
  on_attach = function(client, bufnr)
    if handlers and handlers.on_attach then handlers.on_attach(client, bufnr) end

    client.config.settings = client.config.settings or {}
    client.config.settings.tsserver_file_preferences = client.config.settings.tsserver_file_preferences or {}
    client.config.settings.tsserver_file_preferences.disableSuggestions = true
  end,
  settings = {
    separate_diagnostic_server = true,
    publish_diagnostic_on = "insert_leave",
    expose_as_code_action = "all",
    tsserver_file_preferences = {
      disableSuggestions = true,
      includeCompletionsForModuleExports = true,
      includeCompletionsWithSnippetText = true,
    },
    tsserver_format_options = {
      allowIncompleteCompletions = false,
      allowRenameOfImportPath = false,
    },
    tsserver_path = tsserver_path,
  },
}
