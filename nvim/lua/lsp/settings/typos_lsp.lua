local config_dir = os.getenv "XDG_CONFIG_HOME" or os.getenv "HOME" .. "/.config"
local config_path = config_dir .. "/typos.toml"

return {
  -- Prevent starting on non-file buffers to avoid crashes in older versions
  single_file_support = false,
  init_options = {
    config = vim.fn.filereadable(config_path) == 1 and config_path or nil,
  },
  on_attach = function(client, bufnr)
    -- Disable some features that may cause crashes
    local compat = require "lsp.compat"
    if compat.supports_method(client, "textDocument/formatting") then
      client.server_capabilities.documentFormattingProvider = false
    end
    if compat.supports_method(client, "textDocument/rangeFormatting") then
      client.server_capabilities.documentRangeFormattingProvider = false
    end
  end,
  -- Add timeout and restart configuration
  flags = {
    debounce_text_changes = 300,
  },
  -- Add debug environment for troubleshooting
  cmd_env = {
    RUST_LOG = "warn", -- Only show warnings and errors
    -- Uncomment for debugging: RUST_LOG = "debug", RUST_BACKTRACE = "1"
  },
  -- Handle server crashes gracefully
  on_exit = function(code, signal, client_id)
    if code ~= 0 then vim.notify("typos-lsp exited unexpectedly (code: " .. code .. ")", vim.log.levels.WARN) end
  end,
}
