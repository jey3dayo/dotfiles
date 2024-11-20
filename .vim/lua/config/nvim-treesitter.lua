return {
  highlight = { enable = true, disable = {} },
  indent = { enable = true, disable = {} },
  ensure_installed = require("lsp.config").installed_tree_sitter,
  autotag = { enable = true },
  tree_docs = { enable = true },
  matchup = {
    enable = true,
    -- disable = { "c", "ruby" },
  },
}
