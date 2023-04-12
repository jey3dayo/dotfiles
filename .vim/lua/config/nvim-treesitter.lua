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
    "tsx",
    "toml",
    "json",
    "yaml",
    "css",
    "html",
    "ruby",
    "lua",
    "vim",
  },
  autotag = {
    enable = true,
  },
  rainbow = {
    enable = true,
    -- disablg = { "jsx", "cpp" },
    extended_mode = true,
    max_file_lines = nil,
  },
}

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
