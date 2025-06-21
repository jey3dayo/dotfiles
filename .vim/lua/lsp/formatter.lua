local utils = require "core.utils"
local with = utils.with
local config = require "lsp.config"

local M = {}

local function notify_formatter(name)
  if config.isDebug then vim.notify("Formatted with: " .. name, vim.log.levels.INFO) end
end
M.notify_formatter = notify_formatter

local function format_buffer(bufnr, client, c)
  if vim.g[config.format.state.global] then return nil end

  if config.isDebug then
    vim.notify(string.format("Attempting to format with: %s (id: %d)", client.name, client.id), vim.log.levels.INFO)
  end

  local format_config = with(config.format.default, { bufnr = bufnr, id = client.id }, c)
  vim.lsp.buf.format(format_config)
  notify_formatter(client.name)
end

local function create_format_command(bufnr, client)
  local ok, err = pcall(format_buffer, bufnr, client)
  if not ok then vim.notify("Format failed: " .. err, vim.log.levels.ERROR) end
end

-- グローバルなフォーマットオートコマンドが既に登録済みかを追跡
local _format_autocmd_registered = false

local function get_preferred_format_client(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  local format_clients = vim.tbl_filter(function(c)
    return c.supports_method "textDocument/formatting"
  end, clients)

  if #format_clients == 0 then return nil end

  -- 優先順位: biome > prettier > ts_ls > efm
  local priority_order = { "biome", "prettier", "ts_ls", "efm" }

  for _, preferred_name in ipairs(priority_order) do
    for _, client in ipairs(format_clients) do
      if client.name == preferred_name then return client end
    end
  end

  -- 優先順位にない場合は最初のクライアントを返す
  return format_clients[1]
end

M.setup = function(bufnr, client, args)
  if config.isDebug then
    vim.notify(
      string.format(
        "Setting up formatter for client: %s, supports formatting: %s",
        client.name,
        tostring(client.supports_method "textDocument/formatting")
      ),
      vim.log.levels.INFO
    )
  end
  if not client.supports_method "textDocument/formatting" then return end

  -- グローバルなフォーマットオートコマンドを一度だけ登録
  if not _format_autocmd_registered then
    _format_autocmd_registered = true

    utils.autocmd("BufWritePre", {
      pattern = "*",
      callback = function(event)
        local buf = event.buf
        local preferred_client = get_preferred_format_client(buf)

        if not preferred_client then return end

        if config.isDebug then
          vim.notify(
            string.format("Selected client for formatting: %s (id: %d)", preferred_client.name, preferred_client.id),
            vim.log.levels.INFO
          )
        end

        create_format_command(buf, preferred_client)
      end,
    })
  end

  utils.user_command("Format", function()
    local current_client = vim.lsp.get_client_by_id(args.data.client_id)
    if not current_client then
      vim.notify(args.data.client_id .. " not found", vim.log.levels.WARN)
      return
    end
    create_format_command(bufnr, current_client)
  end, {})
end

return M
