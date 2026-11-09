local M = {}

local SUPPORTED_KEYS = {
  branch = true,
  build = true,
  cmd = true,
  cond = true,
  config = true,
  dependencies = true,
  enabled = true,
  event = true,
  ft = true,
  init = true,
  keys = true,
  lazy = true,
  main = true,
  opts = true,
  priority = true,
  version = true,
}

local SUPPORTED_KEY_FIELDS = { desc = true, mode = true }

local function as_list(value)
  if value == nil then return {} end
  if type(value) == "table" then return value end
  return { value }
end

local function append_unique(list, values)
  for _, value in ipairs(values) do
    if not vim.tbl_contains(list, value) then table.insert(list, value) end
  end
end

local function resolve_version(raw)
  if raw.version == false or raw.version == nil then return raw.branch end
  if type(raw.version) ~= "string" then error("pack: unsupported version value for " .. raw[1]) end
  if raw.version:find("*", 1, true) then return vim.version.range((raw.version:gsub("^v", ""))) end
  return raw.version
end

local function plugin_name(id)
  return (id:match("([^/]+)$"):gsub("%.git$", ""))
end

local function plugin_src(id)
  if id:find("://", 1, true) then return id end
  return "https://github.com/" .. id
end

local function validate(raw)
  for key in pairs(raw) do
    if type(key) == "string" and not SUPPORTED_KEYS[key] then
      error(string.format("pack: unsupported spec key '%s' in %s", key, raw[1]))
    end
  end
  for _, key in ipairs(as_list(raw.keys)) do
    if type(key) == "table" then
      for field in pairs(key) do
        if type(field) == "string" and not SUPPORTED_KEY_FIELDS[field] then
          error(string.format("pack: unsupported key field '%s' in keys of %s", field, raw[1]))
        end
      end
    end
  end
end

local function normalize_keys(raw_keys)
  local keys = {}
  for _, key in ipairs(as_list(raw_keys)) do
    local spec = type(key) == "string" and { key } or key
    if spec[2] ~= false then
      for _, mode in ipairs(as_list(spec.mode or "n")) do
        table.insert(keys, { lhs = spec[1], rhs = spec[2], mode = mode, desc = spec.desc })
      end
    end
  end
  return keys
end

local function new_plugin(raw)
  return {
    name = plugin_name(raw[1]),
    src = plugin_src(raw[1]),
    event = {},
    cmd = {},
    ft = {},
    keys = {},
    dependencies = {},
    opts = {},
  }
end

local function merge_into(plugin, raw)
  for _, field in ipairs { "build", "cond", "config", "enabled", "init", "lazy", "main", "priority" } do
    if raw[field] ~= nil then plugin[field] = raw[field] end
  end
  local version = resolve_version(raw)
  if version ~= nil then plugin.version = version end
  append_unique(plugin.event, as_list(raw.event))
  append_unique(plugin.cmd, as_list(raw.cmd))
  append_unique(plugin.ft, as_list(raw.ft))
  vim.list_extend(plugin.keys, normalize_keys(raw.keys))
  if raw.opts ~= nil then table.insert(plugin.opts, raw.opts) end
end

local function is_single_spec(value)
  return type(value) == "string" or (type(value[1]) == "string" and value[2] == nil)
end

local function collect(raw, result)
  if type(raw) == "string" then raw = { raw } end
  if not is_single_spec(raw) then
    local names = {}
    for _, item in ipairs(raw) do
      append_unique(names, collect(item, result))
    end
    return names
  end

  validate(raw)
  local name = plugin_name(raw[1])
  local plugin = result.plugins[name]
  if not plugin then
    plugin = new_plugin(raw)
    result.plugins[name] = plugin
    table.insert(result.order, name)
  end
  merge_into(plugin, raw)

  if raw.dependencies ~= nil then
    local deps = type(raw.dependencies) == "string" and { raw.dependencies } or raw.dependencies
    append_unique(plugin.dependencies, collect(deps, result))
  end
  return { name }
end

local function check_setup_target(plugin)
  local has_setup = (#plugin.opts > 0 or plugin.config == true) and type(plugin.config) ~= "function"
  if has_setup and not plugin.main then
    error(string.format("pack: %s uses opts or config=true and needs an explicit `main`", plugin.name))
  end
end

---@param raw_specs table[] lazy.nvim style specs
function M.normalize(raw_specs)
  local result = { plugins = {}, order = {} }
  collect(raw_specs, result)
  for _, plugin in pairs(result.plugins) do
    check_setup_target(plugin)
  end
  return result
end

return M
