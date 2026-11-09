local M = {}

local function module_name(file)
  return (file:gsub("%.lua$", ""))
end

---Maps module names to the plugin providing them, looking two levels into each plugin's lua/ directory.
---@param plugins { name: string, dir: string }[]
---@param scan fun(dir: string): { name: string, type: string }[]?
---@return table<string, string>
function M.build_index(plugins, scan)
  local index = {}
  local function add(module, plugin)
    index[module] = index[module] or plugin.name
  end

  for _, plugin in ipairs(plugins) do
    local root = plugin.dir .. "/lua"
    for _, entry in ipairs(scan(root) or {}) do
      if entry.name:match "%.lua$" then
        add(module_name(entry.name), plugin)
      else
        for _, child in ipairs(scan(root .. "/" .. entry.name) or {}) do
          if child.name == "init.lua" then
            add(entry.name, plugin)
          elseif child.name:match "%.lua$" or child.type == "directory" then
            add(entry.name .. "." .. module_name(child.name), plugin)
          end
        end
      end
    end
  end
  return index
end

---Longest indexed module name that is `modname` or one of its parents.
---@param index table<string, string>
---@param modname string
---@return string? plugin_name
function M.provider(index, modname)
  local key = modname
  while key do
    if index[key] then return index[key] end
    key = key:match "^(.+)%.[^.]+$"
  end
end

return M
