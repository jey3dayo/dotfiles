local factory = require("lsp.settings_factory")

return factory.create_formatter_server("eslint", {
  -- CRITICAL: Set workspaceFolder in on_new_config
  on_new_config = function(config, new_root_dir)
    -- Make sure workspaceFolder is set
    config.settings = config.settings or {}
    local root = new_root_dir or vim.fn.getcwd()
    config.settings.workspaceFolder = {
      uri = vim.uri_from_fname(root),
      name = vim.fn.fnamemodify(root, ":t"),
    }
  end,

  on_attach = function(client, bufnr)
    -- Call base on_attach first
    local handlers = require("lsp.handlers")
    if handlers and handlers.on_attach then
      handlers.on_attach(client, bufnr)
    end

    -- Disable formatting only (ESLint should be used for linting, not formatting)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,

  settings = {
    -- Basic ESLint settings
    validate = "on",
    packageManager = "npm",
    autoFixOnSave = false,
    format = false,
    quiet = false,
    onIgnoredFiles = "off",
    rulesCustomizations = {},
    run = "onType",
    -- Working directory settings
    workingDirectory = {
      mode = "location",
    },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine",
      },
      showDocumentation = {
        enable = true,
      },
    },
  },
}
