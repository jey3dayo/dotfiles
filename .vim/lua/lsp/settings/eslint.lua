local utils = require "core.utils"
local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.eslint.config_files

return {
  init_options = {
    provideFormatter = false,
  },
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  autostart = utils.has_config_files(config_files),
}
