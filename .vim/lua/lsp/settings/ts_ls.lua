local utils = require "utils"
local ft = require "utils/filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.ts_ls.config_files

local function has_typescript_dependency()
  if not utils.check_file_exists "package.json" then return false end

  local grep_result = vim.fn.system "grep -c 'typescript' package.json"
  return tonumber(grep_result) > 0
end

return {
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
    tsserver = {
      useSyntaxServer = "never",
    },
  },
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  -- autostart = utils.has_config_files(config_files) or has_typescript_dependency(),
  autostart = false,
}
