local wezterm_ok, wezterm = pcall(require, "wezterm")

local M = {}

local function ensure_wezterm()
  assert(wezterm_ok, "wezterm module is required for this helper")
  return wezterm
end

local function home_dir()
  local home = os.getenv "HOME" or os.getenv "USERPROFILE"
  if type(home) ~= "string" or home == "" then return nil end
  return home
end

function M.font_with_fallback(name, params)
  local wez = ensure_wezterm()
  local constants = require "./constants"
  local names = { name }
  for _, fallback in ipairs(constants.font.fallbacks) do
    table.insert(names, fallback)
  end
  return wez.font_with_fallback(names, params)
end

function M.truncate_right(title, max_width)
  if type(title) ~= "string" then title = "" end
  if type(max_width) ~= "number" or max_width <= 0 then return "" end

  local text = M.basename(title)
  if #text <= max_width then return text end

  local ellipsis = "..."
  if max_width <= #ellipsis then return ellipsis:sub(1, max_width) end

  return text:sub(1, max_width - #ellipsis) .. ellipsis
end

function M.basename(s)
  if type(s) ~= "string" then return "" end
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function M.merge_tables(t1, t2)
  for k, v in pairs(t2) do
    if (type(v) == "table") and (type(t1[k] or false) == "table") then
      M.merge_tables(t1[k], t2[k])
    else
      t1[k] = v
    end
  end
  return t1
end

function M.merge_lists(t1, t2)
  local result = {}
  for _, v in ipairs(t1) do
    table.insert(result, v)
  end
  for _, v in ipairs(t2) do
    table.insert(result, v)
  end
  return result
end

function M.exists(tab, element)
  for _, v in pairs(tab) do
    if v == element then
      return true
    elseif type(v) == "table" then
      return M.exists(v, element)
    end
  end
  return false
end

function M.abbreviate_home_dir(path)
  if type(path) ~= "string" then return path end
  local home = home_dir()
  if not home then return path end

  if path == home then return "~" end
  if path:sub(1, #home) == home then
    local remainder = path:sub(#home + 1)
    if remainder == "" or remainder:match "^[/\\]" then return "~" .. remainder end
  end

  return path
end

function M.convert_home_dir(path)
  if type(path) ~= "string" then return path end
  local home = home_dir()
  if not home then return path end

  if path == "~" then return home end

  local remainder = path:match "^~([/\\].*)$"
  if remainder then return home .. remainder end

  return path
end

function M.file_exists(fname)
  local file = io.open(fname, "r")
  if file then
    file:close()
    return true
  end
  return false
end

function M.convert_useful_path(dir)
  local cwd = M.convert_home_dir(dir)
  return M.basename(cwd)
end

function M.split_from_url(dir)
  if type(dir) ~= "string" then return "", "" end
  local hostname = ""
  local path = ""

  local scheme, rest = dir:match "^([%w%+%.%-]+)://(.+)$"
  local uri_path = rest or dir

  if scheme and uri_path:sub(1, 1) ~= "/" then
    local host_part, path_part = uri_path:match "^([^/]+)(/.*)$"
    hostname = host_part or ""
    path = path_part or ""
  else
    path = uri_path
  end

  if hostname:find "@" then hostname = hostname:match "@(.+)$" or hostname end
  local dot = hostname:find "[.]"
  if dot then hostname = hostname:sub(1, dot - 1) end

  local cwd = path ~= "" and M.convert_useful_path(path) or ""
  return hostname, cwd
end

local function is_array(value)
  return type(value) == "table" and (value[1] ~= nil or next(value) == nil)
end

function M.array_concat(self, ...)
  local items = { ... }
  local result = {}
  local len = 0
  for i = 1, #self do
    len = len + 1
    result[len] = self[i]
  end
  for i = 1, #items do
    local item = items[i]
    if is_array(item) then
      for j = 1, #item do
        len = len + 1
        result[len] = item[j]
      end
    else
      len = len + 1
      result[len] = item
    end
  end
  return result
end

return M
