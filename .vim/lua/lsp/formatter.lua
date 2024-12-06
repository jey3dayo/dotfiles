local with = require("utils").with
local config = require "lsp.config"

local M = {}

local function notify_formatter(name)
  if config.isDebug then
    vim.notify("Formatted with: " .. name, vim.log.levels.INFO)
  end
end
M.notify_formatter = notify_formatter

local function format_buffer(bufnr, client, c)
  if vim.g[config.format.state.global] then
    return nil
  end

  local format_config = with(config.format.default, { bufnr = bufnr, id = client.id }, c)
  vim.lsp.buf.format(format_config)
  notify_formatter(client.name)
end

local function create_format_command(bufnr, client)
  local ok, err = pcall(format_buffer, bufnr, client)
  if not ok then
    vim.notify("Format failed: " .. err, vim.log.levels.ERROR)
  end
end

M.setup = function(bufnr, client, args)
  if not client.supports_method "textDocument/formatting" then
    return
  end

  autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function()
      create_format_command(bufnr, client)
    end,
  })

  vim.api.nvim_create_user_command("Format", function()
    local current_client = vim.lsp.get_client_by_id(args.data.client_id)
    if not current_client then
      vim.notify(args.data.client_id .. " not found", vim.log.levels.WARN)
      return
    end
    create_format_command(bufnr, current_client)
  end, {})
end

return M
