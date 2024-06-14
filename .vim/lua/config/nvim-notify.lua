local notify = safe_require "notify"

if not notify then
  return
end

vim.notify = notify
