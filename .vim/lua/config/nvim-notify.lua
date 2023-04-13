local status1, notify = pcall(require, "notify")
if not status1 then
  return
end

local status2, telescope = pcall(require, "telescope")
if not status2 then
  return
end

-- telescope.extensions.notify.notify({})

vim.notify = notify

telescope.load_extension "notify"
