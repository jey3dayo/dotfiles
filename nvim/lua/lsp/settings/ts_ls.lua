local factory = require "lsp.settings_factory"

return factory.create_js_server("ts_ls", {
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
    tsserver = {
      useSyntaxServer = "never",
    },
  },
  on_attach = function(client, bufnr)
    -- Call base on_attach first
    local handlers = require "lsp.handlers"
    if handlers and handlers.on_attach then handlers.on_attach(client, bufnr) end

    -- Disable verbose logging at server level
    client.config.settings = client.config.settings or {}
    client.config.settings.typescript = client.config.settings.typescript or {}
    client.config.settings.typescript.preferences = client.config.settings.typescript.preferences or {}
    client.config.settings.typescript.preferences.disableTypeScriptVersions = true
  end,
})
