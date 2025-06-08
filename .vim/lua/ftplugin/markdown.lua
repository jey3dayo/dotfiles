-- Ensure treesitter highlighting is started for markdown buffers
if vim.treesitter.get_parser then
  vim.treesitter.start(0, "markdown")
end
