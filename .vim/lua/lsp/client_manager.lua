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

function M.should_stop_client(client)
  return client.name == "tsserver" and vim.lsp.get_clients({ name = "biome" })[1]
end

return M
