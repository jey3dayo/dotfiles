return {
  highlight = {
    enable = true,
    disable = function(_, buf)
      -- Disable for large files (>2MB) to prevent freezes
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok and stats and stats.size > 1024 * 1024 * 2
    end,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
    disable = function(_, buf)
      -- Disable for large files (>2MB)
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok and stats and stats.size > 1024 * 1024 * 2
    end,
  },
  ensure_installed = require("lsp.config").installed_tree_sitter,
  autotag = { enable = true },
  tree_docs = { enable = true },
  matchup = {
    enable = true,
  },
}
