local ft = require("core.filetypes")
local lsp_utils = require("lsp.utils")
local lsp_config = require("lsp.config")
local config_files = lsp_config.formatters.tailwindcss.config_files

return {
  init_options = {
    includeLanguages = {
      eruby = "erb",
      eelixir = "html-eex",
      ["javascript.jsx"] = "javascriptreact",
    },
  },
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.tailwind_supported,
  settings = {
    tailwindCSS = {
      validate = true,
    },
  },
}
