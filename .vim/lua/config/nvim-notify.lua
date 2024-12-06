local notify = Safe_require "notify"

if not notify then
  return
end

vim.notify = notify
