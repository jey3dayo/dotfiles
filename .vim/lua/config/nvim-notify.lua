local notify = safe_require "notify"
local telescope = safe_require "telescope"

if not (notify and telescope) then
  return
end

-- telescope.extensions.notify.notify({})

vim.notify = notify

telescope.load_extension "notify"
