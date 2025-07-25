return {
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true, disable = {} },
  ensure_installed = require("lsp.config").installed_tree_sitter,
  autotag = { enable = true },
  tree_docs = { enable = true },
  matchup = {
    enable = true,
  },
}
