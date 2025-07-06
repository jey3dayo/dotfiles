local utils = require "core.utils"
local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.eslint.config_files

-- Get the project root directory
local function get_root_dir()
  local root = lsp_utils.create_root_pattern(config_files)(vim.fn.expand('%:p'))
  return root or vim.fn.getcwd()
end

return {
  -- ESLintは設定ファイルが存在する場合のみ起動
  autostart = function()
    return utils.has_config_files(config_files)
  end,
  
  cmd = { "vscode-eslint-language-server", "--stdio" },
  
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  
  -- Initialize with proper workspaceFolder to prevent path errors
  init_options = {
    provideFormatter = false,
  },
  
  -- Ensure proper initialization parameters
  before_init = function(params)
    -- Get the root directory for this buffer
    local root = params.rootPath or params.rootUri and vim.uri_to_fname(params.rootUri) or vim.fn.getcwd()
    
    -- Ensure initializationOptions has workspaceFolder
    params.initializationOptions = params.initializationOptions or {}
    params.initializationOptions.workspaceFolder = {
      uri = vim.uri_from_fname(root),
      name = vim.fn.fnamemodify(root, ':t'),
    }
  end,
  
  -- Add on_new_config to ensure settings are properly applied
  on_new_config = function(config, new_root_dir)
    -- Ensure root directory is valid
    local root = new_root_dir or vim.fn.getcwd()
    
    -- Update settings with current root directory
    config.settings = config.settings or {}
    config.settings.workspaceFolder = {
      uri = vim.uri_from_fname(root),
      name = vim.fn.fnamemodify(root, ':t'),
    }
    config.settings.workingDirectory = config.settings.workingDirectory or {}
    config.settings.workingDirectory.directory = root
  end,
  
  -- Critical: Set workspaceFolder before server initialization
  settings = {
    validate = "on",
    packageManager = "npm",
    autoFixOnSave = false,
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine"
      },
      showDocumentation = {
        enable = true
      }
    },
    codeActionOnSave = {
      enable = false,
      mode = "all"
    },
    format = false,
    quiet = false,
    onIgnoredFiles = "off",
    options = {},
    run = "onType",
    -- Fix for v4.9.0+ path error
    workspaceFolder = {
      uri = vim.uri_from_fname(get_root_dir()),
      name = vim.fn.fnamemodify(get_root_dir(), ':t'),
    },
    workingDirectory = {
      mode = "location"
    },
    -- Required empty settings for non-VS Code editors (GitHub issue #2008)
    nodePath = "",
    experimental = {
      useFlatConfig = false,
    },
    problems = {},
    rulesCustomizations = {},
  },
  
  on_attach = function(client, bufnr)
    -- Disable formatting
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    
    -- Force disable pull diagnostics
    client.server_capabilities.diagnosticProvider = nil
  end,
  
  -- Completely disable pull diagnostics capability
  capabilities = (function()
    local cap = require("lsp.capabilities").setup()
    cap.textDocument = cap.textDocument or {}
    cap.textDocument.diagnostic = nil
    return cap
  end)(),
  
  -- Override handlers to prevent diagnostic pull errors
  handlers = {
    ["textDocument/diagnostic"] = function()
      -- Do nothing, return empty result
      return { kind = "full", items = {} }
    end,
  },
}