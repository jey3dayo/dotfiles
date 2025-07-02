local formatters = require("lsp.config").formatters
local safe_client = require("lsp.safe_client")

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
  local clients = safe_client.get_clients({ bufnr = bufnr })
  if #clients == 0 then
    vim.notify("No active LSP clients found", vim.log.levels.WARN)
    return {}
  end

  return vim.tbl_filter(function(c)
    return c:supports_method("textDocument/formatting")
  end, clients)
end

-- フルパスからファイル名のみを抽出
local function extract_formatter_name(command)
  if not command then return nil end
  local name = command:match "^([^ ]+)"
  return name and (name:match "[^/\\]+$" or name)
end

local function get_efm_clients(client, buf_ft)
  local clients = client.config.settings.languages[buf_ft] or {}
  local names = {}

  for _, c in ipairs(clients) do
    if c.formatCommand then table.insert(names, extract_formatter_name(c.formatCommand)) end
  end

  return names
end

function M.get_lsp_client_names(bufnr)
  local clients = safe_client.get_clients({ bufnr = bufnr })
  local buf_ft = vim.bo.filetype

  local client_names = {}
  local seen = {}
  if #clients == 0 then return client_names end

  for _, client in pairs(clients) do
    if client:supports_method("textDocument/formatting") then
      if client.name == "efm" then
        vim.list_extend(client_names, get_efm_clients(client, buf_ft))
      elseif not seen[client.name] then
        table.insert(client_names, client.name)
        seen[client.name] = true
      end
    end
  end

  return client_names
end

-- Get all active LSP clients (for display purposes)
function M.get_all_lsp_client_names(bufnr)
  local clients = safe_client.get_clients({ bufnr = bufnr })
  local client_names = {}
  local seen = {}

  if #clients == 0 then return client_names end

  for _, client in pairs(clients) do
    if not seen[client.name] then
      table.insert(client_names, client.name)
      seen[client.name] = true
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
  -- 同じ名前のクライアントが既に存在するかチェック
  local existing_clients = safe_client.get_clients({ bufnr = bufnr, name = client.name })
  local duplicate_count = 0
  for _, existing_client in ipairs(existing_clients) do
    if existing_client.id ~= client.id then
      duplicate_count = duplicate_count + 1
    end
  end
  
  -- 重複がある場合、新しいクライアント（IDが大きい方）を停止
  if duplicate_count > 0 then
    local older_client = nil
    for _, existing_client in ipairs(existing_clients) do
      if existing_client.id ~= client.id and (not older_client or existing_client.id < older_client.id) then
        older_client = existing_client
      end
    end
    
    if older_client and client.id > older_client.id then
      return true
    end
  end

  -- 既存のフォーマッター優先順位チェック
  -- 実際にアクティブなLSPクライアントのみをチェック
  local active_clients = safe_client.get_clients({ bufnr = bufnr })
  local active_formatter_clients = {}
  
  for _, active_client in ipairs(active_clients) do
    if active_client.id ~= client.id and active_client:supports_method("textDocument/formatting") then
      table.insert(active_formatter_clients, active_client.name)
    end
  end

  for _, active_formatter_name in ipairs(active_formatter_clients) do
    local formatter_config = formatters[active_formatter_name]
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
