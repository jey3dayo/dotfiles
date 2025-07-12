local utils = require "core.utils"
local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.eslint.config_files

return {
  -- ESLintは設定ファイルが存在する場合のみ起動
  autostart = function()
    return utils.has_config_files(config_files)
  end,

  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,

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
