-- Marksman configuration with URI handling fixes
return {
  on_attach = function(client, bufnr)
    -- Disable workspace folders to prevent URI parsing issues
    client.server_capabilities.workspaceFolders = false
    client.server_capabilities.workspace = {
      workspaceFolders = {
        supported = false,
        changeNotifications = false,
      },
    }
  end,
  -- Avoid problematic workspace folder initialization
  root_dir = function()
    return vim.fn.getcwd()
  end,
  single_file_support = true,
}
