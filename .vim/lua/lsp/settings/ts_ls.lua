local ft = require("utils/filetypes")
local lsp_utils = require("lsp.utils")
local lsp_config = require("lsp.config")
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
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  autostart = false,
}
