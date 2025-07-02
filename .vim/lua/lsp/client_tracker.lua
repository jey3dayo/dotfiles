-- LSP Client Tracker - Track and log LSP client lifecycle
local M = {}

-- Store client info: id -> {name, attached_buffers, start_time}
local client_registry = {}

-- Initialize tracking for LSP clients
function M.setup()
  -- Setup tracker when module is loaded
end

-- Auto-setup when module is required
M.setup()

-- Setup autocmds after initial load
vim.defer_fn(function()
  -- Track client start
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        if client_registry[client_id] then
          -- クライアントが既に存在する場合、バッファを追加
          local existing = client_registry[client_id]
          if not vim.tbl_contains(existing.buffers, args.buf) then
            table.insert(existing.buffers, args.buf)
          end
        else
          -- 新しいクライアントを登録
          client_registry[client_id] = {
            id = client_id,
            name = client.name,
            buffers = { args.buf },
            start_time = vim.loop.hrtime(),
            pid = client.rpc and client.rpc.pid or nil,
          }
        end
        vim.notify(string.format("[LSP] Client attached: %s (id=%d, buf=%d)", client.name, client_id, args.buf), vim.log.levels.DEBUG)
      end
    end
  })

  -- Track client detach
  vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(args)
      local client_id = args.data.client_id
      local info = client_registry[client_id]
      
      -- より詳細なdetach情報をログ
      local client_name = info and info.name or "unknown"
      vim.notify(string.format("[LSP] Detach event: %s (id=%d) from buf=%d", 
        client_name, client_id, args.buf), vim.log.levels.DEBUG)
      
      if info then
        -- Remove buffer from tracking
        local buffers = info.buffers or {}
        for i, buf in ipairs(buffers) do
          if buf == args.buf then
            table.remove(buffers, i)
            break
          end
        end
        
        if #buffers == 0 then
          local stop_reason = "all buffers detached"
          vim.notify(string.format("[LSP] Client stopped: %s (id=%d) - %s", info.name, client_id, stop_reason), vim.log.levels.DEBUG)
          client_registry[client_id] = nil
        else
          vim.notify(string.format("[LSP] Client detached: %s (id=%d) from buf=%d, remaining buffers: %d", 
            info.name, client_id, args.buf, #buffers), vim.log.levels.DEBUG)
        end
      end
    end
  })
end, 0)

-- Get client info by ID
function M.get_client_info(client_id)
  return client_registry[client_id]
end

-- Get all registered clients
function M.get_all_clients()
  return client_registry
end

-- Show current LSP clients status
function M.show_status()
  local lines = { "LSP Client Status:", "" }
  
  -- Active clients
  local active = vim.lsp.get_clients()
  table.insert(lines, "Active Clients:")
  for _, client in ipairs(active) do
    local info = client_registry[client.id]
    local status = string.format("  [%d] %s", client.id, client.name)
    if info and info.buffers then
      status = status .. string.format(" (tracked buffers: %d)", #info.buffers)
    else
      status = status .. " (not tracked)"
    end
    table.insert(lines, status)
  end
  
  table.insert(lines, "")
  table.insert(lines, "Registry History:")
  for id, info in pairs(client_registry) do
    local active_client = vim.lsp.get_client_by_id(id)
    local status = active_client and "active" or "inactive"
    table.insert(lines, string.format("  [%d] %s - %s", id, info.name, status))
  end
  
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Create user command
vim.api.nvim_create_user_command("LspStatus", function()
  M.show_status()
end, { desc = "Show LSP client status and history" })

return M