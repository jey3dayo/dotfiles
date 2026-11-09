local ok, err = pcall(function()
  require("pack").setup()
end)
if not ok then
  vim.schedule(function()
    vim.notify("pack setup failed: " .. tostring(err), vim.log.levels.ERROR)
  end)
end

require("core.module_loader").preload_common()
