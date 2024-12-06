local M = {}

M.find_command = function(paths)
  for _, path in ipairs(paths) do
    local file = io.open(path, "r")
    if file then
      file:close()
      return path
    end
  end
  return nil
end

M.extend = function(tab1, tab2)
  for _, value in ipairs(tab2 or {}) do
    table.insert(tab1, value)
  end
  return tab1
end

M.get_git_dir = function()
  local git_dir = vim.fn.finddir(".git", vim.fn.expand "%:p:h" .. ";")
  if git_dir ~= "" then
    git_dir = vim.fn.fnamemodify(git_dir, ":h")
  end
  return git_dir
end

---@param base table 基本となるテーブル
---@param ... table 拡張するテーブル
M.with = function(base, ...)
  local result = vim.deepcopy(base)
  local tables = { ... }

  for _, extend in ipairs(tables) do
    if extend and type(extend) == "table" and not vim.tbl_isempty(extend) then
      result = vim.tbl_extend("force", result, extend)
    end
  end

  return result
end

local function table_to_string(tbl, indent)
  if not indent then
    indent = 0
  end
  local toprint = string.rep(" ", indent) .. "{\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if type(k) == "number" then
      toprint = toprint .. "[" .. k .. "] = "
    elseif type(k) == "string" then
      toprint = toprint .. k .. "= "
    end
    if type(v) == "number" then
      toprint = toprint .. v .. ",\n"
    elseif type(v) == "string" then
      toprint = toprint .. '"' .. v .. '",\n'
    elseif type(v) == "table" then
      toprint = toprint .. table_to_string(v, indent + 2) .. ",\n"
    else
      toprint = toprint .. '"' .. tostring(v) .. '",\n'
    end
  end
  toprint = toprint .. string.rep(" ", indent - 2) .. "}"
  return toprint
end

M.table_to_string = table_to_string

M.print_map = function(tab)
  print(table_to_string(tab))
end

return M
