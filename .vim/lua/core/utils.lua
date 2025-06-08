local M = {}

-- Safe require function
function M.safe_require(module)
  local ok, result = pcall(require, module)
  if not ok then
    return nil
  end
  return result
end

-- Vim API shortcuts (local to avoid globals)
M.autocmd = vim.api.nvim_create_autocmd
M.augroup = vim.api.nvim_create_augroup
M.user_command = vim.api.nvim_create_user_command

-- File system utilities
function M.find_command(paths)
  for _, path in ipairs(paths) do
    local file = io.open(path, "r")
    if file then
      file:close()
      return path
    end
  end
  return nil
end

function M.check_file_exists(filename)
  return vim.fn.findfile(filename, ".;") ~= ""
end

function M.has_config_files(config_files)
  for _, file in ipairs(config_files) do
    if M.check_file_exists(file) then
      return true
    end
  end
  return false
end

-- Table utilities
function M.extend(tab1, tab2)
  for _, value in ipairs(tab2 or {}) do
    table.insert(tab1, value)
  end
  return tab1
end

---@param base table 基本となるテーブル
---@param ... table 拡張するテーブル
function M.with(base, ...)
  local result = vim.deepcopy(base)
  local tables = { ... }

  for _, extend in ipairs(tables) do
    if extend and type(extend) == "table" and not vim.tbl_isempty(extend) then
      result = vim.tbl_extend("force", result, extend)
    end
  end

  return result
end

-- Git utilities
function M.get_git_dir()
  local git_dir = vim.fn.finddir(".git", vim.fn.expand("%:p:h") .. ";")
  if git_dir ~= "" then
    git_dir = vim.fn.fnamemodify(git_dir, ":h")
  end
  return git_dir
end

-- Debug utilities
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

function M.print_map(tab)
  print(table_to_string(tab))
end

-- OS detection
---@return "windows"|"wsl"|"mac"|"linux"|"unknown"
function M.get_os()
  if os.getenv("WSLENV") then
    return "wsl"
  elseif vim.fn.has("mac") == 1 then
    return "mac"
  elseif vim.fn.has("win32") == 1 then
    return "windows"
  elseif vim.fn.has("unix") == 1 then
    return "linux"
  end
  return "unknown"
end

return M
