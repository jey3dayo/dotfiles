local M = {}

function M.setup_web_lang(opts)
  opts = opts or {}
  local tabstop = opts.tabstop or 2
  local shiftwidth = opts.shiftwidth or tabstop

  vim.opt_local.wrap = false
  vim.opt_local.tabstop = tabstop
  vim.opt_local.textwidth = 0
  vim.opt_local.shiftwidth = shiftwidth
  vim.opt_local.expandtab = true
end

function M.setup_js_like(run_cmd, test_cmd)
  M.setup_web_lang { tabstop = 2 }

  if run_cmd then vim.keymap.set("n", "[lsp]j", string.format('<cmd>:!%s "%%"<CR>', run_cmd), { desc = "Run file" }) end
  if test_cmd then vim.keymap.set("n", "[lsp]J", string.format('<cmd>:!%s "%%"<CR>', test_cmd), { desc = "Test file" }) end
end

return M
