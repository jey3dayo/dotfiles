require "nvim.spec.spec_helper"

describe("pack.modules", function()
  local modules

  before_each(function()
    package.loaded["pack.modules"] = nil
    modules = require "pack.modules"
  end)

  local function fake_scan(tree)
    return function(dir)
      return tree[dir]
    end
  end

  local plugins = {
    { name = "mini.pick", dir = "/p/mini.pick" },
    { name = "yanky.nvim", dir = "/p/yanky.nvim" },
    { name = "noice.nvim", dir = "/p/noice.nvim" },
    { name = "gitsigns.nvim", dir = "/p/gitsigns.nvim" },
  }

  local scan = fake_scan {
    ["/p/mini.pick/lua"] = { { name = "mini", type = "directory" } },
    ["/p/mini.pick/lua/mini"] = { { name = "pick.lua", type = "file" } },
    ["/p/yanky.nvim/lua"] = { { name = "yanky", type = "directory" }, { name = "yanky.lua", type = "file" } },
    ["/p/yanky.nvim/lua/yanky"] = { { name = "picker", type = "directory" }, { name = "config.lua", type = "file" } },
    ["/p/noice.nvim/lua"] = { { name = "noice", type = "directory" }, { name = "telescope", type = "directory" } },
    ["/p/noice.nvim/lua/noice"] = { { name = "init.lua", type = "file" } },
    ["/p/noice.nvim/lua/telescope"] = { { name = "_extensions", type = "directory" } },
    ["/p/gitsigns.nvim/lua"] = { { name = "gitsigns", type = "directory" }, { name = "gitsigns.lua", type = "file" } },
    ["/p/gitsigns.nvim/lua/gitsigns"] = { { name = "actions.lua", type = "file" } },
  }

  local function exists_in(files)
    return function(plugin_name, modname)
      return files[plugin_name .. ":" .. modname] == true
    end
  end

  local all_files = exists_in {
    ["mini.pick:mini.pick"] = true,
    ["yanky.nvim:yanky"] = true,
    ["yanky.nvim:yanky.picker"] = true,
    ["yanky.nvim:yanky.config"] = true,
    ["noice.nvim:noice"] = true,
    ["noice.nvim:telescope._extensions.noice"] = true,
    ["yanky.nvim:telescope._extensions.yanky"] = true,
    ["fidget.nvim:telescope._extensions.fidget"] = true,
    ["gitsigns.nvim:gitsigns.actions"] = true,
  }

  local shared_plugins = {
    { name = "yanky.nvim", dir = "/p/yanky.nvim" },
    { name = "noice.nvim", dir = "/p/noice.nvim" },
    { name = "fidget.nvim", dir = "/p/fidget.nvim" },
  }

  local shared_scan = fake_scan {
    ["/p/yanky.nvim/lua"] = { { name = "telescope", type = "directory" } },
    ["/p/yanky.nvim/lua/telescope"] = { { name = "_extensions", type = "directory" } },
    ["/p/noice.nvim/lua"] = { { name = "telescope", type = "directory" } },
    ["/p/noice.nvim/lua/telescope"] = { { name = "_extensions", type = "directory" } },
    ["/p/fidget.nvim/lua"] = { { name = "telescope", type = "directory" } },
    ["/p/fidget.nvim/lua/telescope"] = { { name = "_extensions", type = "directory" } },
  }

  it("indexes top-level files, init.lua directories and second-level modules", function()
    local index = modules.build_index(plugins, scan)

    assert.are.same({ "mini.pick" }, index["mini.pick"])
    assert.are.same({ "yanky.nvim" }, index["yanky"])
    assert.are.same({ "yanky.nvim" }, index["yanky.picker"])
    assert.are.same({ "yanky.nvim" }, index["yanky.config"])
    assert.are.same({ "noice.nvim" }, index["noice"])
    assert.are.same({ "gitsigns.nvim" }, index["gitsigns.actions"])
  end)

  it("does not claim a bare namespace directory as a module", function()
    local index = modules.build_index(plugins, scan)

    assert.is_nil(index["mini"])
    assert.is_nil(index["telescope"])
  end)

  it("resolves a module to the plugin providing it", function()
    local index = modules.build_index(plugins, scan)

    assert.are.equal("mini.pick", modules.provider(index, "mini.pick", all_files))
    assert.are.equal("yanky.nvim", modules.provider(index, "yanky.picker", all_files))
    assert.are.equal("gitsigns.nvim", modules.provider(index, "gitsigns.actions", all_files))
  end)

  it("picks the plugin that owns the requested file when several share a namespace directory", function()
    local index = modules.build_index(shared_plugins, shared_scan)

    assert.are.equal("fidget.nvim", modules.provider(index, "telescope._extensions.fidget", all_files))
    assert.are.equal("noice.nvim", modules.provider(index, "telescope._extensions.noice", all_files))
    assert.are.equal("yanky.nvim", modules.provider(index, "telescope._extensions.yanky", all_files))
  end)

  it("returns nil when no candidate has the requested file", function()
    local index = modules.build_index(shared_plugins, shared_scan)

    assert.is_nil(modules.provider(index, "telescope._extensions.unknown", all_files))
    assert.is_nil(modules.provider(index, "yanky.picker.sub.module", all_files))
    assert.is_nil(modules.provider(index, "mini.unknown", all_files))
    assert.is_nil(modules.provider(index, "no.such.module", all_files))
  end)

  it("skips plugins whose lua directory cannot be scanned", function()
    local index = modules.build_index({ { name = "broken", dir = "/p/broken" } }, fake_scan {})

    assert.are.same({}, index)
  end)
end)
