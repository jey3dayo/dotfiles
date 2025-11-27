-- Modern formatter using conform.nvim with backward compatibility
local utils = require "core.utils"
local with = utils.with
local config = require "lsp.config"

local M = {}

local function resolve_bufnr(bufnr)
  if not bufnr or bufnr == 0 then return vim.api.nvim_get_current_buf() end
  return bufnr
end

-- Helper function to get conform status
local function get_conform_formatters(bufnr)
  local ok, conform = pcall(require, "conform")
  if not ok then return {} end

  local formatters = conform.list_formatters(bufnr or 0)
  local available = {}
  for _, formatter in ipairs(formatters) do
    if formatter.available then table.insert(available, formatter.name) end
  end
  return available
end

-- Notification function for debugging
local function notify_formatter(name, method)
  method = method or "conform"
  local message = "Formatted with: " .. name .. " (" .. method .. ")"
  if config.isDebug then vim.notify(message, vim.log.levels.INFO) end
end
M.notify_formatter = notify_formatter

-- Modern formatting using conform.nvim
local function format_with_conform(bufnr, formatter_name)
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("conform.nvim not available", vim.log.levels.ERROR)
    return false
  end

  local format_opts = {
    bufnr = bufnr,
    timeout_ms = 3000,
  }

  -- If specific formatter requested, use it
  if formatter_name then format_opts.formatters = { formatter_name } end

  local success = conform.format(format_opts)
  if success then
    local used_formatter = formatter_name or "auto-detected"
    notify_formatter(used_formatter, "conform")
    return true
  end

  return false
end

-- Fallback to LSP formatting
local function format_with_lsp(bufnr, client)
  if not client or not client:supports_method "textDocument/formatting" then return false end

  local format_config = with(config.format.default, { bufnr = bufnr, id = client.id })
  vim.lsp.buf.format(format_config)
  notify_formatter(client.name, "LSP")
  return true
end

-- Get preferred LSP client (for fallback only when conform fails)
local function get_preferred_format_client(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  local format_clients = vim.tbl_filter(function(c)
    return c:supports_method "textDocument/formatting"
  end, clients)

  if #format_clients == 0 then return nil end

  -- For LSP fallback, use first available client
  -- conform.nvim handles the smart selection based on config files
  return format_clients[1]
end

-- Main formatting function
local function format_buffer(bufnr, options)
  options = options or {}
  local specific_formatter = options.formatter

  if vim.g[config.format.state.global] then return nil end

  -- Try conform.nvim first
  if format_with_conform(bufnr, specific_formatter) then return end

  -- Fallback to LSP if conform fails
  if not specific_formatter then
    local clients = vim.lsp.get_clients { bufnr = bufnr }
    local format_clients = vim.tbl_filter(function(c)
      return c:supports_method "textDocument/formatting"
    end, clients)

    if #format_clients > 0 then
      local preferred_client = get_preferred_format_client(bufnr)
      if preferred_client and format_with_lsp(bufnr, preferred_client) then return end
    end
  end

  vim.notify("No formatters available", vim.log.levels.WARN)
end

-- Safe command creation
local function create_format_command(bufnr, options)
  local target = resolve_bufnr(bufnr)
  local ok, err = pcall(format_buffer, target, options)
  if not ok then vim.notify("Format failed: " .. err, vim.log.levels.ERROR) end
end

-- Auto-format setup
local _format_autocmd_registered = false
local _format_commands_registered = false

local function register_autocmd()
  if _format_autocmd_registered then return end
  _format_autocmd_registered = true

  utils.autocmd("BufWritePre", {
    pattern = "*",
    callback = function(event)
      local buf = event.buf
      local buf_vars = vim.b[buf] or {}

      -- Check if auto-format is disabled
      if vim.g.disable_autoformat or buf_vars.disable_autoformat then return end

      create_format_command(buf)
    end,
  })
end

local function register_commands()
  if _format_commands_registered then return end
  _format_commands_registered = true

  -- Universal format command (targets current buffer)
  utils.user_command("Format", function()
    create_format_command()
  end, { desc = "Format buffer with auto-detection" })

  -- Specific formatter commands
  local function create_specific_formatter_command(formatter_name)
    return function()
      local bufnr = resolve_bufnr()

      -- First try conform.nvim
      if format_with_conform(bufnr, formatter_name) then return end

      -- Fallback to LSP client with matching name
      local clients = vim.lsp.get_clients { bufnr = bufnr }
      for _, lsp_client in ipairs(clients) do
        if lsp_client.name == formatter_name and lsp_client:supports_method "textDocument/formatting" then
          if format_with_lsp(bufnr, lsp_client) then return end
        end
      end

      vim.notify(formatter_name .. " not available", vim.log.levels.WARN)
    end
  end

  -- Create specific formatter commands
  utils.user_command("FormatWithBiome", create_specific_formatter_command "biome", { desc = "Format with Biome" })
  utils.user_command(
    "FormatWithPrettier",
    create_specific_formatter_command "prettier",
    { desc = "Format with Prettier" }
  )
  utils.user_command("FormatWithEslint", create_specific_formatter_command "eslint_d", { desc = "Format with ESLint" })
  utils.user_command("FormatWithTsLs", create_specific_formatter_command "ts_ls", { desc = "Format with TypeScript" })

  -- Debug command (uses current buffer)
  utils.user_command("FormatInfo", function()
    local bufnr = resolve_bufnr()
    local conform_formatters = get_conform_formatters(bufnr)
    local lsp_clients = vim.tbl_map(function(c)
      return c.name
    end, vim.lsp.get_clients { bufnr = bufnr })

    local msg = "Formatting options:\n"
    msg = msg .. "Conform formatters: " .. table.concat(conform_formatters, ", ") .. "\n"
    msg = msg .. "LSP clients: " .. table.concat(lsp_clients, ", ")

    vim.notify(msg, vim.log.levels.INFO)
  end, { desc = "Show formatting info" })
end

M.setup = function(bufnr, client, args)
  if config.isDebug then
    vim.notify(string.format("Setting up modern formatter for buffer: %d", bufnr), vim.log.levels.INFO)
  end

  register_autocmd()
  register_commands()
end

return M
