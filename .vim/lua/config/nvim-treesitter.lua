local ts = safe_require "nvim-treesitter.configs"
local parsers = safe_require "nvim-treesitter.parsers"
if not (ts and parsers) then
  return
end

ts.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = require("lsp.config").installed_tree_sitter,
  autotag = {
    enable = true,
  },
  tree_docs = { enable = true },
  matchup = {
    enable = true,
    -- disable = { "c", "ruby" },
  },
}

local parser_config = parsers.get_parser_configs()
