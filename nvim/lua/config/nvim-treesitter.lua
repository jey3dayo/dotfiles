local utils = require "core.utils"

local function disable_for_large_files(_, buf)
  -- Disable for large files (>2MB)
  return utils.is_large_file(buf, 1024 * 1024 * 2)
end

return {
  highlight = {
    enable = true,
    disable = disable_for_large_files,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = disable_for_large_files,
  },
  ensure_installed = require("lsp.config").installed_tree_sitter,
  autotag = { enable = true },
  tree_docs = { enable = true },
  matchup = {
    enable = true,
  },
  auto_install = true,
}
