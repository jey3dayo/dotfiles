--- Clean LSP notification control at protocol level
--- @module lsp.quiet
--- Provides noise suppression for LSP notifications while preserving errors
local M = {}

local config = require("lsp.config")

--- Setup LSP quiet mode with intelligent message filtering
--- @return nil
function M.setup()
  -- Set LSP log level to OFF to minimize file logging
  vim.lsp.set_log_level("OFF")
  
  -- Store original notify
  local original_notify = vim.notify
  
  -- Override vim.notify to filter LSP noise at source
  vim.notify = function(msg, level, opts)
    -- Convert to string if necessary
    local msg_str = tostring(msg)
    
    if type(msg_str) == "string" and (
      msg_str:find("No client with id", 1, true) or
      msg_str:find("client with id", 1, true) or
      msg_str:find("connections closed", 1, true) or
      msg_str:find("stderr", 1, true) or
      msg_str:find("rpc", 1, true) or
      -- ESLintのパスエラーを完全に抑制（大文字小文字を無視）
      msg_str:lower():find("eslint") and msg_str:lower():find("path") and msg_str:lower():find("string") or
      msg_str:find("32603", 1, true) and msg_str:find("textDocument/diagnostic", 1, true) or
      msg_str:find("The \"path\" argument must be of type string", 1, true) or
      msg_str:find("Request textDocument/diagnostic failed", 1, true)
    ) then
      -- Log to file for debugging if needed
      if vim.g.lsp_debug then
        local log_file = vim.fn.stdpath("cache") .. "/suppressed_lsp_errors.log"
        local file = io.open(log_file, "a")
        if file then
          file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. msg_str .. "\n")
          file:close()
        end
      end
      return -- Silently suppress LSP noise
    end
    return original_notify(msg, level, opts)
  end
  
  -- Handle window/logMessage cleanly
  vim.lsp.handlers["window/logMessage"] = function(err, result, ctx, cfg)
    -- Only show ERROR level messages, suppress INFO/WARN
    if result and result.type == vim.lsp.protocol.MessageType.Error then
      original_notify(result.message, vim.log.levels.ERROR)
    end
    -- Silently ignore INFO/WARN messages (TypeScript version, server initialized, etc.)
  end
  
  -- Handle window/showMessage cleanly  
  vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, cfg)
    -- Only show ERROR level messages
    if result and result.type == vim.lsp.protocol.MessageType.Error then
      original_notify(result.message, vim.log.levels.ERROR)
    end
    -- Silently ignore INFO/WARN messages
  end
  
  -- Fix MethodNotFound error by adding minimal workspace handlers
  vim.lsp.handlers['workspace/workspaceFolders'] = function()
    local cwd = vim.loop.cwd()
    return { { uri = vim.uri_from_fname(cwd), name = cwd } }
  end

  vim.lsp.handlers['workspace/configuration'] = function(_, params)
    local items = {}
    for _ in ipairs(params.items) do
      -- Return empty settings table as fallback
      table.insert(items, {})
    end
    return items
  end
  
  -- Store original for debug toggle
  M._original_notify = original_notify
end

--- Toggle between quiet and debug modes for troubleshooting
--- @return nil
function M.toggle_debug()
  if vim.lsp.get_log_level() == vim.log.levels.OFF then
    vim.lsp.set_log_level("WARN")
    -- Restore original notify and verbose handlers
    vim.notify = M._original_notify
    vim.lsp.handlers["window/logMessage"] = nil
    vim.lsp.handlers["window/showMessage"] = nil
    M._original_notify("LSP debug mode: ON", vim.log.levels.INFO)
  else
    M.setup() -- Re-apply quiet mode
    M._original_notify("LSP debug mode: OFF", vim.log.levels.INFO)
  end
end

-- Auto-setup
M.setup()

-- Create debug command
vim.api.nvim_create_user_command("LspQuietToggle", M.toggle_debug, { 
  desc = "Toggle LSP quiet/debug mode" 
})

return M