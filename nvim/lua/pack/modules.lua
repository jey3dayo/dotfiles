local M = {}

local function module_name(file)
  return (file:gsub("%.lua$", ""))
end

---Maps module names to the plugins that may provide them, looking two levels into each plugin's lua/ directory.
---Several plugins can share a namespace directory (e.g. telescope/_extensions), so each key holds a list.
---@param plugins { name: string, dir: string }[]
---@param scan fun(dir: string): { name: string, type: string }[]?
---@return table<string, string[]>
function M.build_index(plugins, scan)
  local index = {}
  local function add(module, plugin)
    local names = index[module] or {}
    index[module] = names
    if names[#names] ~= plugin.name then table.insert(names, plugin.name) end
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

---Plugin that owns the file of `modname`, trying the longest indexed prefix first.
---@param index table<string, string[]>
---@param modname string
---@param exists fun(plugin_name: string, modname: string): boolean whether the plugin has the module's file
---@return string? plugin_name
function M.provider(index, modname, exists)
  local key = modname
  while key do
    for _, plugin_name in ipairs(index[key] or {}) do
      if exists(plugin_name, modname) then return plugin_name end
    end
    key = key:match "^(.+)%.[^.]+$"
  end
end

return M
