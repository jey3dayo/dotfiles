--- LSP Client Tracker - Track and log LSP client lifecycle with performance monitoring
--- @module lsp.client_tracker
local M = {}

--- Store client info: id -> {name, attached_buffers, start_time, metrics}
--- @type table<number, {id: number, name: string, buffers: number[], start_time: number, pid?: number, attach_time?: number}>
local client_registry = {}

--- Initialize LSP client tracking with immediate autocmd setup
--- Optimized to avoid defer_fn for better startup performance
--- @return nil
function M.setup()
  -- Track client attachment with performance metrics
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LSPClientTracker", { clear = true }),
    callback = function(args)
      local client_id = args.data.client_id
      local client = vim.lsp.get_client_by_id(client_id)
      local current_time = vim.loop.hrtime()
      
      if not client then return end
      
      if client_registry[client_id] then
        -- Client exists, add buffer if not already tracked
        local existing = client_registry[client_id]
        if not vim.tbl_contains(existing.buffers, args.buf) then
          table.insert(existing.buffers, args.buf)
        end
      else
        -- Register new client with performance tracking
        client_registry[client_id] = {
          id = client_id,
          name = client.name,
          buffers = { args.buf },
          start_time = current_time,
          attach_time = current_time,
          pid = client.rpc and client.rpc.pid or nil,
        }
      end
    end
  })

  -- Track client detachment with cleanup
  vim.api.nvim_create_autocmd("LspDetach", {
    group = vim.api.nvim_create_augroup("LSPClientTracker", { clear = false }),
    callback = function(args)
      local client_id = args.data.client_id
      local info = client_registry[client_id]
      
      if not info then return end
      
      -- Remove buffer from tracking
      local buffers = info.buffers or {}
      for i = #buffers, 1, -1 do
        if buffers[i] == args.buf then
          table.remove(buffers, i)
          break
        end
      end
      
      -- Clean up client registry if no buffers remain
      if #buffers == 0 then
        client_registry[client_id] = nil
      end
    end
  })
end

-- Initialize tracking immediately when module is loaded
M.setup()

--- Get client information by ID
--- @param client_id number Client ID to lookup
--- @return table|nil Client info or nil if not found
function M.get_client_info(client_id)
  return client_registry[client_id]
end

--- Get all registered clients
--- @return table<number, table> All client registry data
function M.get_all_clients()
  return client_registry
end

--- Get performance metrics for a client
--- @param client_id number Client ID
--- @return table|nil Performance metrics
function M.get_client_metrics(client_id)
  local info = client_registry[client_id]
  if not info then return nil end
  
  local current_time = vim.loop.hrtime()
  return {
    uptime_ms = (current_time - info.start_time) / 1000000,
    buffer_count = #info.buffers,
    name = info.name,
    pid = info.pid,
  }
end

--- Show current LSP clients status with enhanced metrics
--- @return nil
function M.show_status()
  local lines = { "📊 LSP Client Status & Performance", "" }
  
  -- Active clients with metrics
  local active = vim.lsp.get_clients()
  table.insert(lines, "🔴 Active Clients:")
  
  for _, client in ipairs(active) do
    local metrics = M.get_client_metrics(client.id)
    local status = string.format("  [%d] %s", client.id, client.name)
    
    if metrics then
      status = status .. string.format(" (uptime: %.1fms, buffers: %d)", 
                                       metrics.uptime_ms, metrics.buffer_count)
      if metrics.pid then
        status = status .. string.format(" [PID:%d]", metrics.pid)
      end
    else
      status = status .. " (not tracked)"
    end
    table.insert(lines, status)
  end
  
  table.insert(lines, "")
  table.insert(lines, "📈 Registry History:")
  local registry_count = 0
  for id, info in pairs(client_registry) do
    registry_count = registry_count + 1
    local active_client = vim.lsp.get_client_by_id(id)
    local status_icon = active_client and "🟢" or "🔴"
    local status = active_client and "active" or "inactive"
    table.insert(lines, string.format("  %s [%d] %s - %s", status_icon, id, info.name, status))
  end
  
  table.insert(lines, "")
  table.insert(lines, string.format("Total tracked clients: %d", registry_count))
  
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

-- Create enhanced user commands
vim.api.nvim_create_user_command("LspStatus", function()
  M.show_status()
end, { desc = "Show LSP client status and performance metrics" })

vim.api.nvim_create_user_command("LspMetrics", function(args)
  local client_id = tonumber(args.args)
  if client_id then
    local metrics = M.get_client_metrics(client_id)
    if metrics then
      vim.notify(vim.inspect(metrics), vim.log.levels.INFO)
    else
      vim.notify("Client not found: " .. client_id, vim.log.levels.WARN)
    end
  else
    -- Show all metrics
    for id, _ in pairs(client_registry) do
      local metrics = M.get_client_metrics(id)
      if metrics then
        vim.notify(string.format("[%d] %s: %.1fms uptime", id, metrics.name, metrics.uptime_ms), vim.log.levels.INFO)
      end
    end
  end
end, { nargs = '?', desc = "Show LSP client performance metrics" })

return M