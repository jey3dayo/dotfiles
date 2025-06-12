local ft = require "core.filetypes"
local lsp_utils = require "lsp.utils"
local lsp_config = require "lsp.config"
local config_files = lsp_config.formatters.ts_ls.config_files

local config = {
  init_options = {
    preferences = {
      disableSuggestions = true,
    },
    tsserver = {
      useSyntaxServer = "never",
    },
  },
  settings = {
    -- FIXME: 動いてる気がしない
    tsserver_locale = "ja",
    tsserver_file_preferences = {
      separateRequireAndTypeImports = true,
      organizeImportsCollation = "ordinal",
      organizeImportsCollationLocale = "ja",
    },
  },
  root_dir = lsp_utils.create_root_pattern(config_files),
  filetypes = ft.js_project,
  -- TypeScript LSP should always be available
  -- autostart = true, -- デフォルトでtrue
}

return config
