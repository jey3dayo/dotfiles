local factory = require "lsp.settings_factory"
local lsp_utils = require "lsp.utils"

local function resolve_tsserver_path()
  return lsp_utils.get_mason_package_path("typescript-language-server", "node_modules/typescript/lib/tsserver.js")
end

local tsserver_path = resolve_tsserver_path()

local config = factory.create_js_server("typescript-tools", {
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
})

local base_on_attach = config.on_attach
config.on_attach = function(client, bufnr)
  if base_on_attach then base_on_attach(client, bufnr) end

  client.config.settings = client.config.settings or {}
  client.config.settings.tsserver_file_preferences = client.config.settings.tsserver_file_preferences or {}
  client.config.settings.tsserver_file_preferences.disableSuggestions = true
end

return config
