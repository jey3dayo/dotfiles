local config_dir = os.getenv "XDG_CONFIG_HOME" or os.getenv "HOME" .. "/.config"
local config_path = config_dir .. "/typos.toml"

return {
  init_options = { 
    config = vim.fn.filereadable(config_path) == 1 and config_path or nil
  },
  on_attach = function(client, bufnr)
    -- Disable some features that may cause crashes
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
  -- Add timeout and restart configuration
  flags = {
    debounce_text_changes = 300,
  },
  -- Handle server crashes gracefully
  on_exit = function(code, signal, client_id)
    if code ~= 0 then
      vim.notify("typos-lsp exited unexpectedly (code: " .. code .. ")", vim.log.levels.WARN)
    end
  end,
}
