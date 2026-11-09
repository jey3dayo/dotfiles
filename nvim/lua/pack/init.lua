local handlers = require "pack.handlers"
local spec = require "pack.spec"

local M = { plugins = {}, order = {} }

-- Runtime plugins that lazy.nvim skipped via performance.rtp.disabled_plugins; the value is each plugin's loaded_* guard.
local DISABLED_RUNTIME_GUARDS = {
  "loaded_gzip",
  "loaded_matchit",
  "loaded_matchparen",
  "loaded_netrwPlugin",
  "loaded_tarPlugin",
  "loaded_zipPlugin",
  "loaded_tutor_mode_plugin",
}

local function notify_error(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.ERROR)
  end)
end

local function try(label, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if not ok then notify_error(string.format("pack: %s failed: %s", label, err)) end
  return ok
end

local function plugin_specs_from_config()
  local dir = vim.fn.stdpath "config" .. "/lua/plugins"
  local modules = {}
  for name, kind in vim.fs.dir(dir) do
    if kind == "file" and name:match "%.lua$" then table.insert(modules, name:sub(1, -5)) end
  end
  table.sort(modules)

  local raw = {}
  for _, module in ipairs(modules) do
    table.insert(raw, require("plugins." .. module))
  end
  return raw
end

local function has_trigger(plugin)
  return #plugin.event + #plugin.cmd + #plugin.ft + #plugin.keys > 0
end

local function is_enabled(plugin)
  if plugin.enabled == false then return false end
  if type(plugin.cond) == "function" then return plugin.cond(plugin) and true or false end
  return plugin.cond ~= false
end

local function classify(plugin)
  if plugin.lazy == false then return "start" end
  if has_trigger(plugin) then return "trigger" end
  return "rtp"
end

local function source_after_plugin(plugin)
  local files = vim.fn.glob(plugin.dir .. "/after/plugin/**/*.vim", false, true)
  vim.list_extend(files, vim.fn.glob(plugin.dir .. "/after/plugin/**/*.lua", false, true))
  table.sort(files)
  for _, file in ipairs(files) do
    vim.cmd.source(vim.fn.fnameescape(file))
  end
end

-- During init.lua `packadd!` is required: Nvim sources plugin/ and after/ itself afterwards, and a plain
-- `packadd` would source plugin/ twice. Later loads need `packadd`, which skips after/plugin/.
local function add_to_runtime(plugin)
  if plugin.added then return end
  plugin.added = true
  if vim.v.vim_did_init == 0 then
    vim.cmd.packadd { args = { plugin.name }, bang = true }
    return
  end
  vim.cmd.packadd(plugin.name)
  source_after_plugin(plugin)
end

local function resolve_opts(plugin)
  local opts
  for _, part in ipairs(plugin.opts) do
    if type(part) == "function" then
      local current = opts or {}
      opts = part(plugin, current) or current
    elseif opts == nil then
      opts = part
    else
      opts = vim.tbl_deep_extend("force", opts, part)
    end
  end
  return opts or {}
end

local function run_config(plugin)
  if not ((plugin.config ~= nil and plugin.config ~= false) or #plugin.opts > 0) then return end
  local opts = resolve_opts(plugin)
  if type(plugin.config) == "function" then
    plugin.config(plugin, opts)
  else
    require(plugin.main).setup(opts)
  end
end

local function run_build(plugin, path)
  if not plugin.dir then plugin.dir = path end
  add_to_runtime(plugin)
  if type(plugin.build) == "function" then return plugin.build(plugin) end
  if type(plugin.build) == "string" and plugin.build:sub(1, 1) == ":" then return vim.cmd(plugin.build:sub(2)) end
  error("pack: unsupported build for " .. plugin.name)
end

local function register_build_hook(bootstrap)
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      local data = ev.data
      if bootstrap or data.kind == "delete" then return end
      local plugin = M.plugins[data.spec.name]
      if not (plugin and plugin.build) then return end
      local function build()
        try("build " .. plugin.name, function()
          run_build(plugin, data.path)
        end)
      end
      if vim.v.vim_did_init == 0 then
        vim.schedule(build)
      else
        build()
      end
    end,
  })
end

function M.load(name)
  local plugin = M.plugins[name]
  if not plugin then error("pack: unknown plugin " .. name) end
  if plugin.disabled or plugin.loaded then return end
  plugin.loaded = true
  handlers.disable(name)
  for _, dep in ipairs(plugin.dependencies) do
    M.load(dep)
  end
  try("load " .. name, function()
    add_to_runtime(plugin)
    run_config(plugin)
  end)
end

local function on_add(plug)
  local plugin = M.plugins[plug.spec.name]
  plugin.dir = plug.path
  if plugin.kind ~= "trigger" then add_to_runtime(plugin) end
end

local function pack_specs()
  local specs = {}
  for _, name in ipairs(M.order) do
    local plugin = M.plugins[name]
    if not plugin.disabled then
      table.insert(specs, { src = plugin.src, name = plugin.name, version = plugin.version })
    end
  end
  return specs
end

local function start_plugins()
  local start = {}
  for _, name in ipairs(M.order) do
    local plugin = M.plugins[name]
    if not plugin.disabled and plugin.kind == "start" then table.insert(start, plugin) end
  end
  table.sort(start, function(a, b)
    local pa, pb = a.priority or 50, b.priority or 50
    if pa ~= pb then return pa > pb end
    return a.index < b.index
  end)
  return start
end

local function schedule_very_lazy()
  local function fire()
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then return end
      vim.g.did_very_lazy = true
      handlers.fire_very_lazy()
    end)
  end
  if vim.v.vim_did_enter == 1 then
    fire()
  else
    vim.api.nvim_create_autocmd("UIEnter", { once = true, callback = fire })
  end
end

function M.setup()
  local bootstrap = vim.env.NVIM_PACK_BOOTSTRAP == "1"

  for _, guard in ipairs(DISABLED_RUNTIME_GUARDS) do
    vim.g[guard] = 1
  end

  local normalized = spec.normalize(plugin_specs_from_config())
  M.plugins, M.order = normalized.plugins, normalized.order
  for index, name in ipairs(M.order) do
    local plugin = M.plugins[name]
    plugin.index = index
    plugin.disabled = not is_enabled(plugin)
    plugin.kind = classify(plugin)
  end

  handlers.setup(M.load)
  register_build_hook(bootstrap)

  try("vim.pack.add", function()
    vim.pack.add(pack_specs(), { confirm = not bootstrap, load = on_add })
  end)

  for _, name in ipairs(M.order) do
    local plugin = M.plugins[name]
    if not plugin.disabled and plugin.init then try("init " .. name, function()
      plugin.init(plugin)
    end) end
  end

  for _, name in ipairs(M.order) do
    local plugin = M.plugins[name]
    if not plugin.disabled and plugin.kind == "trigger" then handlers.enable(plugin) end
  end

  for _, plugin in ipairs(start_plugins()) do
    M.load(plugin.name)
  end

  schedule_very_lazy()
end

return M
