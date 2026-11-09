local M = {}

local group = vim.api.nvim_create_augroup("pack_handler_event", { clear = true })

-- Events re-fired in this order so that autocmds created by a late-loaded plugin still run for the triggering buffer.
local EVENT_CHAIN = { FileType = "BufReadPost", BufReadPost = "BufReadPre" }

local loader
local teardowns = {}
local event_defs = {}
local key_stubs = {}

local function add_teardown(name, fn)
  teardowns[name] = teardowns[name] or {}
  table.insert(teardowns[name], fn)
end

local function notify_error(message)
  vim.schedule(function()
    vim.notify(message, vim.log.levels.ERROR)
  end)
end

local function augroup_names(event)
  local names = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = event }) do
    if autocmd.group_name then table.insert(names, autocmd.group_name) end
  end
  return names
end

local function snapshot(event, buf, data)
  local state = {}
  while event do
    table.insert(state, 1, {
      event = event,
      exclude = event ~= "FileType" and augroup_names(event) or nil,
      buffer = buf,
      data = data,
    })
    data = nil
    event = EVENT_CHAIN[event]
  end
  return state
end

local function exec_autocmds(opts)
  local ok, err = pcall(vim.api.nvim_exec_autocmds, opts.event, {
    buffer = opts.buffer,
    group = opts.group,
    modeline = false,
    data = opts.data,
  })
  if not ok then notify_error(string.format("pack: failed to re-fire %s: %s", opts.event, err)) end
end

local function refire(opts)
  if opts.group or opts.exclude == nil then return exec_autocmds(opts) end
  local done = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = opts.event }) do
    local id = autocmd.event .. ":" .. (autocmd.group or "")
    local skip = done[id] or vim.tbl_contains(opts.exclude, autocmd.group_name)
    done[id] = true
    if autocmd.group and not skip then
      opts.group = autocmd.group_name
      exec_autocmds(opts)
    end
  end
end

local function parse_event(spec)
  if spec == "VeryLazy" then return { id = "VeryLazy", event = "User", pattern = "VeryLazy" } end
  local event, pattern = spec:match "^(%w+)%s+(.*)$"
  return { id = spec, event = event or spec, pattern = pattern }
end

local function create_event_def(def)
  local registered = { id = def.id, names = {}, active = {}, done = false }
  vim.api.nvim_create_autocmd(def.event, {
    group = group,
    once = true,
    pattern = def.pattern,
    callback = function(ev)
      if registered.done then return end
      registered.done = true
      local pending = vim.tbl_filter(function(name)
        return registered.active[name]
      end, registered.names)
      if #pending == 0 then return end
      local state = def.id ~= "VeryLazy" and snapshot(ev.event, ev.buf, ev.data) or {}
      for _, name in ipairs(pending) do
        loader(name)
      end
      for _, s in ipairs(state) do
        refire(s)
      end
    end,
  })
  return registered
end

local function register_event(name, def)
  local registered = event_defs[def.id]
  if not registered then
    registered = create_event_def(def)
    event_defs[def.id] = registered
  end
  table.insert(registered.names, name)
  registered.active[name] = true
  add_teardown(name, function()
    registered.active[name] = nil
  end)
end

local function register_cmd(name, cmd)
  vim.api.nvim_create_user_command(cmd, function(event)
    local command = {
      cmd = cmd,
      bang = event.bang or nil,
      mods = event.smods,
      args = event.fargs,
      count = event.count >= 0 and event.range == 0 and event.count or nil,
    }
    if event.range == 1 then
      command.range = { event.line1 }
    elseif event.range == 2 then
      command.range = { event.line1, event.line2 }
    end

    loader(name)

    local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
    if not info then
      notify_error(string.format("pack: command %s not found after loading %s", cmd, name))
      return
    end
    command.nargs = info.nargs
    if event.args and event.args ~= "" and info.nargs and info.nargs:find "[1?]" then command.args = { event.args } end
    vim.cmd(command)
  end, {
    bang = true,
    range = true,
    nargs = "*",
    complete = function(_, line)
      loader(name)
      return vim.fn.getcompletion(line, "cmdline")
    end,
  })
  add_teardown(name, function()
    pcall(vim.api.nvim_del_user_command, cmd)
  end)
end

local function register_key(name, key)
  local id = key.mode .. ":" .. vim.api.nvim_replace_termcodes(key.lhs, true, true, true)
  local stub = key_stubs[id]
  if not stub then
    stub = { plugins = {}, order = {} }
    key_stubs[id] = stub
    vim.keymap.set(key.mode, key.lhs, function()
      for _, pending in ipairs(vim.deepcopy(stub.order)) do
        if stub.plugins[pending] then loader(pending) end
      end
      local feed = vim.api.nvim_replace_termcodes("<Ignore>" .. key.lhs, true, true, true)
      vim.api.nvim_feedkeys(feed, "i", false)
    end, { desc = key.desc, expr = true })
  end
  stub.plugins[name] = key
  table.insert(stub.order, name)
  add_teardown(name, function()
    stub.plugins[name] = nil
    if next(stub.plugins) == nil then
      pcall(vim.keymap.del, key.mode, key.lhs)
      key_stubs[id] = nil
    end
    if key.rhs then vim.keymap.set(key.mode, key.lhs, key.rhs, { desc = key.desc }) end
  end)
end

---@param load fun(name: string) loads a plugin by name (and disables its handlers first)
function M.setup(load)
  loader = load
end

function M.enable(plugin)
  for _, spec in ipairs(plugin.event) do
    register_event(plugin.name, parse_event(spec))
  end
  for _, ft in ipairs(plugin.ft) do
    register_event(plugin.name, { id = "FileType " .. ft, event = "FileType", pattern = ft })
  end
  for _, cmd in ipairs(plugin.cmd) do
    register_cmd(plugin.name, cmd)
  end
  for _, key in ipairs(plugin.keys) do
    register_key(plugin.name, key)
  end
end

function M.disable(name)
  local fns = teardowns[name] or {}
  teardowns[name] = nil
  for _, fn in ipairs(fns) do
    fn()
  end
end

function M.fire_very_lazy()
  vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
end

return M
