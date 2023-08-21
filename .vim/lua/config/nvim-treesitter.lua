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
  ensure_installed = {
    "bash",
    "markdown",
    "markdown_inline",
    "prisma",
    "toml",
    "json",
    "yaml",
    "css",
    "html",
    "ruby",
    "lua",
    "vim",
    "astro",
  },
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
}

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
