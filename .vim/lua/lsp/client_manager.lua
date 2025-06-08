local formatters = require("lsp.config").formatters

local M = {}

local seen_clients = {}

function M.is_client_processed(client_id, bufnr)
  local key = string.format("%d-%d", client_id, bufnr)
  return seen_clients[key] ~= nil
end

function M.mark_client_processed(client_id, bufnr)
  local key = string.format("%d-%d", client_id, bufnr)
  seen_clients[key] = true
end

function M.get_format_clients(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  if clients == 0 then
    vim.notify("No active LSP clients found", vim.log.levels.WARN)
    return {}
  end

  return vim.tbl_filter(function(c)
    return c.supports_method("textDocument/formatting")
  end, clients)
end

-- フルパスからファイル名のみを抽出
local function extract_formatter_name(command)
  if not command then
    return nil
  end
  local name = command:match("^([^ ]+)")
  return name and (name:match("[^/\\]+$") or name)
end

local function get_efm_clients(client, buf_ft)
  local clients = client.config.settings.languages[buf_ft] or {}
  local names = {}

  for _, c in ipairs(clients) do
    if c.formatCommand then
      table.insert(names, extract_formatter_name(c.formatCommand))
    end
  end

  return names
end

function M.get_lsp_client_names(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  local buf_ft = vim.bo.filetype

  local client_names = {}
  if next(clients) == nil then
    return client_names
  end

  for _, client in pairs(clients) do
    if client:supports_method("textDocument/formatting") then
      if client.name == "efm" then
        vim.list_extend(client_names, get_efm_clients(client, buf_ft))
      else
        table.insert(client_names, client.name)
      end
    end
  end

  return client_names
end

function M.format_lsp_clients(bufnr)
  local client_names = M.get_lsp_client_names(bufnr)
  return #client_names > 0 and table.concat(client_names, ",") or "N/A"
end

-- LSPクライアントの優先順位を定義
function M.should_stop_client(client, bufnr)
  local client_names = M.get_lsp_client_names(bufnr)
  if #client_names == 0 then
    return false
  end

  for _, client_name in ipairs(client_names) do
    local formatter_config = formatters[client_name]
    if formatter_config and formatter_config.formatter_priority then
      local formatter = formatter_config.formatter_priority
      if formatter.overrides and formatter.overrides[client.name] then
        return true
      end
    end
  end

  return false
end

return M
