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

  it("indexes top-level files, init.lua directories and second-level modules", function()
    local index = modules.build_index(plugins, scan)

    assert.are.equal("mini.pick", index["mini.pick"])
    assert.are.equal("yanky.nvim", index["yanky"])
    assert.are.equal("yanky.nvim", index["yanky.picker"])
    assert.are.equal("yanky.nvim", index["yanky.config"])
    assert.are.equal("noice.nvim", index["noice"])
    assert.are.equal("gitsigns.nvim", index["gitsigns.actions"])
  end)

  it("does not claim a bare namespace directory as a module", function()
    local index = modules.build_index(plugins, scan)

    assert.is_nil(index["mini"])
    assert.is_nil(index["telescope"])
  end)

  it("resolves a module to the plugin providing it, falling back to parent modules", function()
    local index = modules.build_index(plugins, scan)

    assert.are.equal("mini.pick", modules.provider(index, "mini.pick"))
    assert.are.equal("yanky.nvim", modules.provider(index, "yanky.picker.sub.module"))
    assert.are.equal("noice.nvim", modules.provider(index, "telescope._extensions.noice"))
  end)

  it("returns nil for modules no plugin provides", function()
    local index = modules.build_index(plugins, scan)

    assert.is_nil(modules.provider(index, "mini.unknown"))
    assert.is_nil(modules.provider(index, "no.such.module"))
  end)

  it("skips plugins whose lua directory cannot be scanned", function()
    local index = modules.build_index({ { name = "broken", dir = "/p/broken" } }, fake_scan {})

    assert.are.same({}, index)
  end)
end)
