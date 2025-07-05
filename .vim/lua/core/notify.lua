local M = {}

-- Error messages for common scenarios
M.errors = {
  extension_not_loaded = function(name)
    return string.format("Telescope extension '%s' is not loaded", name)
  end,
  plugin_not_loaded = function(name)
    return string.format("Plugin '%s' is not loaded", name)
  end,
  file_not_found = function(path)
    return string.format("File not found: %s", path)
  end,
  invalid_config = function(config)
    return string.format("Invalid configuration: %s", config)
  end,
}

-- Notification levels
M.levels = {
  ERROR = vim.log.levels.ERROR,
  WARN = vim.log.levels.WARN,
  INFO = vim.log.levels.INFO,
  DEBUG = vim.log.levels.DEBUG,
}

-- Core notification function
function M.notify(message, level, opts)
  opts = opts or {}
  level = level or M.levels.INFO

  -- Use mini.notify if available, fallback to vim.notify
  if vim.notify then
    vim.notify(message, level, opts)
  else
    print(message)
  end
end

-- Convenience functions
function M.error(message, opts)
  M.notify(message, M.levels.ERROR, opts)
end

function M.warn(message, opts)
  M.notify(message, M.levels.WARN, opts)
end

function M.info(message, opts)
  M.notify(message, M.levels.INFO, opts)
end

function M.debug(message, opts)
  M.notify(message, M.levels.DEBUG, opts)
end

return M

