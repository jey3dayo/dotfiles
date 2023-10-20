local status, ts = pcall(require, "nvim-treesitter.configs")
if not status then
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
  rainbow = {
    enable = true,
    -- disablg = { "jsx", "cpp" },
    extended_mode = true,
    max_file_lines = nil,
  },
  context_commentstring = {
    enable = true,
  },
  matchup = {
    enable = true,
    -- disable = { "c", "ruby" },
  },
}

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
