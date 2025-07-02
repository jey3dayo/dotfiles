--- LSP Performance Monitoring - Track startup times and client metrics
--- @module lsp.performance
--- Provides comprehensive performance tracking for LSP operations and startup times

local M = {}

--- Performance metrics storage
--- @type table<string, {start_time: number, end_time?: number, duration?: number}>
local metrics = {}

--- LSP startup time tracking
--- @type table<string, number>
local lsp_startup_times = {}

--- Track performance metric start
--- @param key string Metric identifier
--- @return nil
function M.start_timer(key)
  metrics[key] = {
    start_time = vim.loop.hrtime(),
  }
end

--- Track performance metric end and calculate duration
--- @param key string Metric identifier
--- @return number|nil Duration in milliseconds
function M.end_timer(key)
  local metric = metrics[key]
  if not metric or not metric.start_time then
    return nil
  end
  
  metric.end_time = vim.loop.hrtime()
  metric.duration = (metric.end_time - metric.start_time) / 1000000 -- Convert to ms
  
  return metric.duration
end

--- Get metric duration
--- @param key string Metric identifier  
--- @return number|nil Duration in milliseconds
function M.get_duration(key)
  local metric = metrics[key]
  return metric and metric.duration
end

--- Track LSP server startup time
--- @param server_name string LSP server name
--- @param start_time number Start time in nanoseconds
--- @return nil
function M.track_lsp_startup(server_name, start_time)
  local current_time = vim.loop.hrtime()
  local startup_duration = (current_time - start_time) / 1000000
  lsp_startup_times[server_name] = startup_duration
end

--- Get LSP startup metrics
--- @return table<string, number> Server startup times in milliseconds
function M.get_lsp_metrics()
  return vim.deepcopy(lsp_startup_times)
end

--- Show performance report
--- @return nil
function M.show_report()
  local lines = { "📊 LSP Performance Report", "" }
  
  -- General metrics
  table.insert(lines, "🔧 General Metrics:")
  local has_general = false
  for key, metric in pairs(metrics) do
    if metric.duration then
      table.insert(lines, string.format("  %s: %.2fms", key, metric.duration))
      has_general = true
    end
  end
  if not has_general then
    table.insert(lines, "  No metrics recorded")
  end
  
  table.insert(lines, "")
  
  -- LSP server startup times
  table.insert(lines, "🚀 LSP Server Startup Times:")
  local sorted_servers = {}
  for server, time in pairs(lsp_startup_times) do
    table.insert(sorted_servers, { name = server, time = time })
  end
  
  table.sort(sorted_servers, function(a, b) return a.time < b.time end)
  
  if #sorted_servers == 0 then
    table.insert(lines, "  No LSP servers tracked")
  else
    local total_time = 0
    for _, server in ipairs(sorted_servers) do
      table.insert(lines, string.format("  %s: %.2fms", server.name, server.time))
      total_time = total_time + server.time
    end
    table.insert(lines, "")
    table.insert(lines, string.format("📈 Total LSP startup time: %.2fms", total_time))
    table.insert(lines, string.format("📊 Average per server: %.2fms", total_time / #sorted_servers))
  end
  
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

--- Clear all metrics
--- @return nil
function M.clear_metrics()
  metrics = {}
  lsp_startup_times = {}
  vim.notify("🧹 LSP performance metrics cleared", vim.log.levels.INFO)
end

--- Benchmark function execution time
--- @param name string Benchmark name
--- @param func function Function to benchmark
--- @return any Function return value
function M.benchmark(name, func)
  M.start_timer(name)
  local result = func()
  local duration = M.end_timer(name)
  
  if duration then
    vim.notify(string.format("⏱️  %s: %.2fms", name, duration), vim.log.levels.INFO)
  end
  
  return result
end

-- Setup autocmd to track actual LSP client startup
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LSPPerformanceTracker", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      -- Estimate startup time based on when client becomes available
      local current_time = vim.loop.hrtime()
      M.track_lsp_startup(client.name, current_time - 1000000000) -- Rough 1s estimate
    end
  end
})

-- Create user commands
vim.api.nvim_create_user_command("LspPerf", function()
  M.show_report()
end, { desc = "Show LSP performance report" })

vim.api.nvim_create_user_command("LspPerfClear", function()
  M.clear_metrics()
end, { desc = "Clear LSP performance metrics" })

vim.api.nvim_create_user_command("LspBench", function(args)
  if args.args == "" then
    vim.notify("Usage: :LspBench <lua_expression>", vim.log.levels.WARN)
    return
  end
  
  local func = loadstring("return " .. args.args)
  if func then
    M.benchmark("Manual Benchmark", func)
  else
    vim.notify("Invalid Lua expression", vim.log.levels.ERROR)
  end
end, { nargs = 1, desc = "Benchmark Lua expression execution" })

return M