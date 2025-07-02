local utils = require "core.utils"
local with = utils.with
local config = require "lsp.config"

local M = {}

local function notify_formatter(name, via_efm)
  local message = "Formatted with: " .. name
  if via_efm then
    message = message .. " (via EFM)"
  end
  if config.isDebug then vim.notify(message, vim.log.levels.INFO) end
end
M.notify_formatter = notify_formatter

local function format_buffer(bufnr, client, c)
  if vim.g[config.format.state.global] then return nil end

  if config.isDebug then
    vim.notify(string.format("Attempting to format with: %s (id: %d)", client.name, client.id), vim.log.levels.INFO)
  end

  local format_config = with(config.format.default, { bufnr = bufnr, id = client.id }, c)
  vim.lsp.buf.format(format_config)
  
  -- EFM経由でのフォーマッターの場合、より詳細な情報を表示
  local via_efm = client.name == "efm"
  if via_efm then
    local utils = require "core.utils"
    local formatter_settings = require("lsp.config").formatters
    
    -- 利用可能なフォーマッターを優先順位順にチェック
    local formatters = { "biome", "prettier" }
    local detected_formatter = nil
    
    for _, formatter in ipairs(formatters) do
      if utils.has_config_files(formatter_settings[formatter].config_files) then
        detected_formatter = formatter
        break
      end
    end
    
    if detected_formatter then
      notify_formatter(detected_formatter, true)
    else
      notify_formatter("efm", false)
    end
  else
    notify_formatter(client.name, false)
  end
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
    return c:supports_method("textDocument/formatting")
  end, clients)

  if #format_clients == 0 then return nil end

  -- 優先順位: biome > prettier > eslint > ts_ls > efm
  local priority_order = { "biome", "prettier", "eslint", "ts_ls", "efm" }

  for _, preferred_name in ipairs(priority_order) do
    for _, client in ipairs(format_clients) do
      if client.name == preferred_name then return client end
      
      -- EFMクライアントの場合、内部で利用可能なフォーマッターをチェック
      if (preferred_name == "prettier" or preferred_name == "biome") and client.name == "efm" then
        local utils = require "core.utils"
        local formatter_settings = require("lsp.config").formatters
        local has_formatter = utils.has_config_files(formatter_settings[preferred_name].config_files)
        
        if has_formatter then
          -- EFMが指定フォーマッターを持っている場合、そのフォーマッター相当として扱う
          return client
        end
      end
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
  if not client:supports_method("textDocument/formatting") then return end

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

  -- 汎用フォーマットコマンド
  utils.user_command("Format", function()
    local preferred_client = get_preferred_format_client(bufnr)
    if not preferred_client then
      vim.notify("No formatter available", vim.log.levels.WARN)
      return
    end
    create_format_command(bufnr, preferred_client)
  end, {})

  -- 特定フォーマッター指定コマンド
  local function create_specific_formatter_command(formatter_name)
    return function()
      local clients = vim.lsp.get_clients { bufnr = bufnr }
      local target_client = nil
      
      -- まず直接的なクライアント名をチェック
      for _, client in ipairs(clients) do
        if client.name == formatter_name and client:supports_method("textDocument/formatting") then
          target_client = client
          break
        end
      end
      
      -- EFMクライアント経由で特定フォーマッターが利用可能かチェック
      if not target_client and (formatter_name == "prettier" or formatter_name == "biome") then
        for _, client in ipairs(clients) do
          if client.name == "efm" and client:supports_method("textDocument/formatting") then
            local utils = require "core.utils"
            local formatter_settings = require("lsp.config").formatters
            local has_formatter = utils.has_config_files(formatter_settings[formatter_name].config_files)
            
            if has_formatter then
              target_client = client
              break
            end
          end
        end
      end
      
      if target_client then
        create_format_command(bufnr, target_client)
        local display_name = target_client.name == "efm" and (formatter_name .. " (via EFM)") or target_client.name
        vim.notify("Formatting with: " .. display_name, vim.log.levels.INFO)
      else
        -- デバッグ情報を追加
        local available_clients = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients { bufnr = bufnr })
        vim.notify(string.format("%s not available. Available clients: %s", 
          formatter_name, table.concat(available_clients, ", ")), vim.log.levels.WARN)
      end
    end
  end

  utils.user_command("FormatWithBiome", create_specific_formatter_command("biome"), {})
  utils.user_command("FormatWithPrettier", create_specific_formatter_command("prettier"), {})
  utils.user_command("FormatWithEslint", create_specific_formatter_command("eslint"), {})
  utils.user_command("FormatWithTsLs", create_specific_formatter_command("ts_ls"), {})
  utils.user_command("FormatWithEfm", create_specific_formatter_command("efm"), {})
end

return M
