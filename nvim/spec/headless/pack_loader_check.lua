-- Headless regression checks for the vim.pack loader (nvim/lua/pack). Run with `mise run test:nvim`.
-- Uses fake plugins in a temp dir; vim.pack.add is replaced, so no real plugin or network is needed.

local source = debug.getinfo(1, "S").source:gsub("^@", "")
local nvim_dir = vim.fn.fnamemodify(source, ":p:h:h:h")
vim.opt.runtimepath:prepend(nvim_dir)

local root = vim.fn.tempname()
local config_home = root .. "/xdg"
local site = root .. "/site"
local files = root .. "/files"

local function write_file(path, lines)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  vim.fn.writefile(lines, path)
end

local fake = {
  cmd = {},
  keys = {},
  events = {},
  configs = {},
  notifications = {},
}
_G.fake_pack = fake

local function record(list, entry)
  table.insert(list, entry)
end

-- Plugin specs -------------------------------------------------------------------------------------------------

local function config_of(name, extra)
  return function()
    fake.configs[name] = (fake.configs[name] or 0) + 1
    if extra then extra() end
  end
end

local function define_command(name, opts)
  vim.api.nvim_create_user_command(name, function(o)
    record(fake.cmd, {
      name = name,
      bang = o.bang,
      range = o.range,
      line1 = o.line1,
      line2 = o.line2,
      count = o.count,
      args = o.fargs,
    })
  end, opts)
end

local function record_event(label)
  return function(ev)
    record(fake.events, { label = label, event = ev.event, buf = ev.buf })
  end
end

local function watch_event(label, event, pattern)
  local group = vim.api.nvim_create_augroup("fake_" .. label, { clear = true })
  vim.api.nvim_create_autocmd(event, { group = group, pattern = pattern, callback = record_event(label) })
end

local function press_effect(label)
  return function()
    fake.keys[label] = (fake.keys[label] or 0) + 1
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { label .. ":" .. fake.keys[label] })
  end
end

local specs = {
  {
    "fake/cmd.nvim",
    cmd = "FakeCmd",
    config = config_of("cmd.nvim", function()
      define_command("FakeCmd", { bang = true, range = true, nargs = "*" })
    end),
  },
  {
    "fake/one.nvim",
    cmd = "FakeOne",
    config = config_of("one.nvim", function()
      define_command("FakeOne", { nargs = 1 })
    end),
  },
  {
    "fake/count.nvim",
    cmd = "FakeCount",
    config = config_of("count.nvim", function()
      define_command("FakeCount", { count = 0, nargs = "*" })
    end),
  },
  {
    "fake/keys.nvim",
    keys = { { "<leader>fk", desc = "fake key" } },
    config = config_of("keys.nvim", function()
      vim.keymap.set("n", "<leader>fk", press_effect "keys.nvim", { desc = "fake key" })
    end),
  },
  {
    "fake/keyrhs.nvim",
    keys = { { "<leader>fr", press_effect "keyrhs.nvim", desc = "fake rhs key" } },
    config = config_of "keyrhs.nvim",
  },
  {
    "fake/bufread.nvim",
    event = "BufReadPost",
    config = config_of("bufread.nvim", function()
      watch_event("bufread", "BufReadPost")
    end),
  },
  {
    "fake/newfile.nvim",
    event = "BufNewFile",
    config = config_of("newfile.nvim", function()
      watch_event("newfile", "BufNewFile")
    end),
  },
  {
    "fake/multift.nvim",
    ft = { "faketesta", "faketestb" },
    config = config_of("multift.nvim", function()
      watch_event("multift", "FileType", { "faketesta", "faketestb" })
    end),
  },
  {
    "fake/verylazy.nvim",
    event = "VeryLazy",
    config = config_of "verylazy.nvim",
  },
  {
    "fake/failing.nvim",
    cmd = "FakeFailing",
    config = function()
      fake.configs["failing.nvim"] = (fake.configs["failing.nvim"] or 0) + 1
      error "fake config failure"
    end,
  },
  {
    "fake/after-failing.nvim",
    cmd = "FakeAfterFailing",
    dependencies = { "fake/failing.nvim" },
    config = config_of "after-failing.nvim",
  },
  {
    "fake/lib.nvim",
    config = config_of("lib.nvim", function()
      vim.g.fakelib_configured = true
    end),
  },
}

-- Environment -------------------------------------------------------------------------------------------------

local function plugin_dir(name)
  return string.format("%s/pack/test/opt/%s", site, name)
end

local function prepare_environment()
  vim.env.XDG_CONFIG_HOME = config_home
  write_file(config_home .. "/nvim/lua/plugins/fake.lua", { "return {}" })
  package.preload["plugins.fake"] = function()
    return specs
  end
  vim.opt.runtimepath:prepend(config_home .. "/nvim")
  vim.opt.packpath:prepend(site)

  for _, spec in ipairs(specs) do
    vim.fn.mkdir(plugin_dir((spec[1]:match "([^/]+)$")), "p")
  end
  write_file(plugin_dir "lib.nvim" .. "/lua/fakelib/init.lua", { "return { name = 'fakelib' }" })

  vim.pack = {
    add = function(pack_specs, opts)
      for _, pack_spec in ipairs(pack_specs) do
        opts.load { spec = pack_spec, path = plugin_dir(pack_spec.name) }
      end
    end,
  }

  vim.notify = function(message, level)
    table.insert(fake.notifications, { message = message, level = level })
  end

  write_file(files .. "/existing.txt", { "existing" })
  write_file(files .. "/other.txt", { "other" })
end

-- Test harness ---------------------------------------------------------------------------------------------------

local results = { passed = 0, failed = 0 }

local function check(name, fn)
  local ok, err = xpcall(fn, debug.traceback)
  if ok then
    results.passed = results.passed + 1
    io.stdout:write("PASS " .. name .. "\n")
  else
    results.failed = results.failed + 1
    io.stdout:write("FAIL " .. name .. "\n" .. tostring(err) .. "\n")
  end
end

local function expect_equal(actual, expected, label)
  if not vim.deep_equal(actual, expected) then
    error(string.format("%s: expected %s, got %s", label, vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

local function press(lhs)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, true, true), "tx", false)
end

local function map_of(lhs)
  return vim.fn.maparg(vim.api.nvim_replace_termcodes(lhs, true, true, true), "n", false, true)
end

local function flush()
  vim.wait(20)
end

local function commands_named(name)
  return vim.tbl_filter(function(entry)
    return entry.name == name
  end, fake.cmd)
end

local function events_of(label)
  return vim.tbl_filter(function(entry)
    return entry.label == label
  end, fake.events)
end

-- Checks ----------------------------------------------------------------------------------------------------------

local function run_checks(pack)
  check("cmd stub: forwards bang, range and args, then is replaced by the real command", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "1", "2", "3", "4" })
    expect_equal(pack.plugins["cmd.nvim"].loaded, nil, "loaded before the command")
    vim.cmd "2,3FakeCmd! a b"
    expect_equal(fake.configs["cmd.nvim"], 1, "config runs once")
    local calls = commands_named "FakeCmd"
    expect_equal(#calls, 1, "calls")
    expect_equal(calls[1].bang, true, "bang")
    expect_equal({ calls[1].range, calls[1].line1, calls[1].line2 }, { 2, 2, 3 }, "range")
    expect_equal(calls[1].args, { "a", "b" }, "args")

    vim.cmd "FakeCmd c"
    expect_equal(fake.configs["cmd.nvim"], 1, "config does not run again")
    expect_equal(commands_named("FakeCmd")[2].bang, false, "bang is not set on the real command")
    expect_equal(commands_named("FakeCmd")[2].range, 0, "range is not set on the real command")
    expect_equal(vim.api.nvim_get_commands({})["FakeCmd"].definition, "", "real command is a Lua callback")
  end)

  check("cmd stub: nargs=1 command receives the argument string unsplit", function()
    expect_equal(pack.plugins["one.nvim"].loaded, nil, "loaded before the command")
    vim.cmd "FakeOne first  second"
    expect_equal(fake.configs["one.nvim"], 1, "config runs once")
    expect_equal(commands_named("FakeOne")[1].args, { "first  second" }, "args")
  end)

  check("cmd stub: forwards a count given as a range prefix", function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "1", "2", "3", "4", "5", "6" })
    vim.cmd "5FakeCount a"
    expect_equal(fake.configs["count.nvim"], 1, "config runs once")
    expect_equal(commands_named("FakeCount")[1].count, 5, "count")
    expect_equal(commands_named("FakeCount")[1].args, { "a" }, "args")
    vim.cmd "FakeCount 9"
    expect_equal(commands_named("FakeCount")[2].count, 9, "count after load")
  end)

  check("keys stub: first press loads the plugin and replays the key exactly once", function()
    vim.cmd "enew"
    expect_equal(map_of("<leader>fk").expr, 1, "stub is an expr mapping before the load")
    press "<leader>fk"
    expect_equal(fake.configs["keys.nvim"], 1, "config runs once")
    expect_equal(fake.keys["keys.nvim"], 1, "key effect runs exactly once")
    expect_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "keys.nvim:1" }, "buffer content")
    expect_equal(map_of("<leader>fk").expr, 0, "stub is replaced by the real mapping")
    press "<leader>fk"
    expect_equal(fake.keys["keys.nvim"], 2, "second press uses the real mapping")
    expect_equal(fake.configs["keys.nvim"], 1, "config does not run again")
  end)

  check("keys stub: spec rhs replaces the stub after the load", function()
    vim.cmd "enew"
    press "<leader>fr"
    expect_equal(fake.configs["keyrhs.nvim"], 1, "config runs once")
    expect_equal(fake.keys["keyrhs.nvim"], 1, "rhs runs exactly once")
    expect_equal(map_of("<leader>fr").expr, 0, "stub is replaced by the rhs mapping")
    press "<leader>fr"
    expect_equal(fake.keys["keyrhs.nvim"], 2, "second press")
  end)

  check("event: BufReadPost loads the plugin and re-fires for the first buffer without double-firing others", function()
    local seen = 0
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("fake_existing_owner", { clear = true }),
      callback = function()
        seen = seen + 1
      end,
    })
    vim.cmd("edit " .. vim.fn.fnameescape(files .. "/existing.txt"))
    local buf = vim.api.nvim_get_current_buf()
    expect_equal(fake.configs["bufread.nvim"], 1, "config runs once")
    expect_equal(events_of "bufread", { { label = "bufread", event = "BufReadPost", buf = buf } }, "re-fired event")
    expect_equal(seen, 1, "autocmd registered before the load fires once")
  end)

  check("event: BufNewFile loads the plugin and re-fires for the new buffer", function()
    vim.cmd("edit " .. vim.fn.fnameescape(files .. "/missing.txt"))
    local buf = vim.api.nvim_get_current_buf()
    expect_equal(fake.configs["newfile.nvim"], 1, "config runs once")
    expect_equal(events_of "newfile", { { label = "newfile", event = "BufNewFile", buf = buf } }, "re-fired event")
  end)

  check("event: multi-ft plugin re-fires FileType only for the first ft buffer", function()
    vim.cmd "enew"
    local first = vim.api.nvim_get_current_buf()
    vim.bo.filetype = "faketesta"
    expect_equal(fake.configs["multift.nvim"], 1, "config runs once")
    expect_equal(events_of "multift", { { label = "multift", event = "FileType", buf = first } }, "first ft")

    vim.cmd "enew"
    local second = vim.api.nvim_get_current_buf()
    vim.bo.filetype = "faketestb"
    expect_equal(fake.configs["multift.nvim"], 1, "config does not run again")
    expect_equal(#events_of "multift", 2, "only the natural FileType event fires for the second ft")
    expect_equal(events_of("multift")[2].buf, second, "second ft buffer")
  end)

  check("event: VeryLazy loads the plugin when fired", function()
    expect_equal(fake.configs["verylazy.nvim"], nil, "not loaded before")
    require("pack.handlers").fire_very_lazy()
    expect_equal(fake.configs["verylazy.nvim"], 1, "config runs once")
  end)

  check("failure: a failing config is reported, does not abort, and does not block dependents", function()
    vim.cmd "FakeAfterFailing"
    flush()
    expect_equal(fake.configs["failing.nvim"], 1, "failing config ran")
    expect_equal(fake.configs["after-failing.nvim"], 1, "dependent plugin still loaded")
    local errors = vim.tbl_filter(function(entry)
      return entry.level == vim.log.levels.ERROR and entry.message:find("load failing.nvim failed", 1, true)
    end, fake.notifications)
    expect_equal(#errors, 1, "ERROR notifications for the failing plugin")
    expect_equal(errors[1].message:find("fake config failure", 1, true) ~= nil, true, "message carries the cause")
    expect_equal(pack.plugins["failing.nvim"].loaded, true, "failed plugin is not retried")
  end)

  check("require: requiring a module of an unloaded plugin loads it with its config", function()
    expect_equal(vim.g.fakelib_configured, nil, "not configured before")
    expect_equal(require("fakelib").name, "fakelib", "module")
    expect_equal(vim.g.fakelib_configured, true, "config ran")
    expect_equal(fake.configs["lib.nvim"], 1, "config runs once")
    expect_equal(pcall(require, "fakelib.no_such_module"), false, "missing module still fails")
  end)
end

local function main()
  prepare_environment()
  local pack = require "pack"
  pack.setup()
  flush()
  expect_equal(#fake.notifications, 0, "no notification during setup")
  run_checks(pack)
end

local ok, err = xpcall(main, debug.traceback)
if not ok then
  results.failed = results.failed + 1
  io.stdout:write("ERROR " .. tostring(err) .. "\n")
end
io.stdout:write(string.format("%d passed, %d failed\n", results.passed, results.failed))
vim.fn.delete(root, "rf")
vim.cmd(results.failed > 0 and "cquit 1" or "qall!")
