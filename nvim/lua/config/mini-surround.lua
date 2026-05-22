local M = {}

local mappings = {
  add = "sa",
  delete = "sd",
  find = "sf",
  find_left = "sF",
  highlight = "sh",
  replace = "sr",
  update_n_lines = "sn",
}

local key_order = {
  "add",
  "delete",
  "find",
  "find_left",
  "highlight",
  "replace",
  "update_n_lines",
}

function M.keys()
  local keys = {}
  for _, name in ipairs(key_order) do
    local lhs = mappings[name]
    table.insert(keys, { lhs, mode = { "n", "v" } })
  end
  return keys
end

function M.setup()
  require("mini.surround").setup {
    mappings = mappings,
  }
end

return M
