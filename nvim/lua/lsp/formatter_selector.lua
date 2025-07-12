-- Formatter selector - Choose which formatter to use based on priority
local M = {}

local formatters = require("lsp.config").formatters

-- Get the best formatter for the current buffer
function M.get_best_formatter(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  local available_formatters = {}

  -- Collect all available formatters
  for _, client in ipairs(clients) do
    if client:supports_method "textDocument/formatting" then
      table.insert(available_formatters, {
        name = client.name,
        client = client,
        priority = M.get_formatter_priority(client.name),
      })
    end
  end

  -- Sort by priority (lower number = higher priority)
  table.sort(available_formatters, function(a, b)
    return a.priority < b.priority
  end)

  if #available_formatters > 0 then return available_formatters[1].client end

  return nil
end

-- Get formatter priority
function M.get_formatter_priority(formatter_name)
  local config = formatters[formatter_name]
  if config and config.formatter_priority then return config.formatter_priority.priority end

  -- Default priorities if not configured
  local defaults = {
    biome = 1, -- Highest priority
    prettier = 2,
    eslint = 3, -- Lower priority for formatting (better for linting)
    ts_ls = 4, -- Lowest priority for formatting (better for diagnostics)
  }

  return defaults[formatter_name] or 99
end

-- Check if a formatter should be used for formatting (not just diagnostics)
function M.should_format_with(client_name)
  -- These are primarily linters, not formatters
  local lint_only = {
    eslint = true, -- Use for diagnostics, not formatting
    ts_ls = true, -- Use for TypeScript diagnostics, not formatting
  }

  -- If biome is available, don't use prettier
  local config = formatters[client_name]
  if config and config.formatter_priority and config.formatter_priority.overrides then
    -- This logic is already in place
    return true
  end

  return not lint_only[client_name]
end

return M
