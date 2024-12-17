function Safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then return nil end
  return result
end

autocmd = vim.api.nvim_create_autocmd
augroup = vim.api.nvim_create_augroup
user_command = vim.api.nvim_create_user_command
