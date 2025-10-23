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

function M.setup_js_like(run_cmd, test_cmd, bufnr)
  M.setup_web_lang { tabstop = 2 }

  local function set_keymap(lhs, command, desc)
    local opts = { desc = desc, silent = true }
    if bufnr then opts.buffer = bufnr end
    vim.keymap.set("n", lhs, command, opts)
  end

  if run_cmd then set_keymap("[lsp]j", string.format('<cmd>:!%s "%%"<CR>', run_cmd), "Run file") end
  if test_cmd then set_keymap("[lsp]J", string.format('<cmd>:!%s "%%"<CR>', test_cmd), "Test file") end
end

return M
