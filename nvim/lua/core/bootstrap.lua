if vim.loader then vim.loader.enable() end

local loader = require "core.module_loader"

local function safe_require(module_name, opts)
  local module = loader.safe_require(module_name)
  if module then return module end

  if not opts or not opts.optional then
    vim.schedule(function()
      vim.notify(string.format("Failed to load module: %s", module_name), vim.log.levels.WARN)
    end)
  end

  return nil
end

local function load_modules(modules)
  for _, entry in ipairs(modules) do
    if not entry.when or entry.when() then safe_require(entry.name, entry) end
  end
end

local immediate_modules = {
  { name = "lsp.quiet" }, -- quiet LSP logs before anything else
  { name = "core.utils" }, -- utility shortcuts used by later modules
  { name = "core.compat" }, -- compatibility shims for deprecated APIs
  { name = "options" }, -- core options
  { name = "keymaps" }, -- basic keymaps + leader
  { name = "filetype" }, -- filetype detection overrides
  { name = "init_lazy" }, -- plugin manager bootstrap
}

local deferred_modules = {
  { name = "lua_rocks" },
  { name = "autocmds" },
  { name = "colorscheme" },
  { name = "load_config" },
  { name = "lsp.autoformat" },
  {
    name = "neovide",
    when = function()
      return vim.g.neovide
    end,
  },
}

local M = {}
local initialized = false

function M.setup()
  if initialized then return end
  initialized = true

  -- Use volatile state directory to keep config lean
  vim.env.XDG_STATE_HOME = "/tmp"

  load_modules(immediate_modules)

  -- Defer heavier modules until after UI is ready
  vim.defer_fn(function()
    load_modules(deferred_modules)
  end, 0)
end

return M
