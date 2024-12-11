local utils = require "utils"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.config_files.eslint

return {
  init_options = {
    provideFormatter = false,
  },
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  autostart = utils.has_config_file(config_files),
}
