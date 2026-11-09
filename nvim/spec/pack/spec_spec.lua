require "nvim.spec.spec_helper"

describe("pack.spec", function()
  local spec

  local original_tbl_contains, original_version

  before_each(function()
    original_tbl_contains, original_version = vim.tbl_contains, vim.version
    vim.tbl_contains = vim.tbl_contains
      or function(list, value)
        for _, item in ipairs(list) do
          if item == value then return true end
        end
        return false
      end
    vim.version = {
      range = function(text)
        return { range = text }
      end,
    }
    package.loaded["pack.spec"] = nil
    spec = require "pack.spec"
  end)

  after_each(function()
    vim.tbl_contains, vim.version = original_tbl_contains, original_version
    package.loaded["pack.spec"] = nil
  end)

  it("merges specs that name the same plugin and keeps bare dependencies out of the triggers", function()
    local result = spec.normalize {
      { "nvim-lua/plenary.nvim", lazy = true },
      { "a/b", event = "VeryLazy", dependencies = { { "nvim-lua/plenary.nvim" } } },
      { "c/d", dependencies = "nvim-lua/plenary.nvim" },
    }

    assert.are.same({ "plenary.nvim", "b", "d" }, result.order)
    assert.are.same({}, result.plugins["plenary.nvim"].event)
    assert.are.same({ "plenary.nvim" }, result.plugins.b.dependencies)
    assert.are.same({ "plenary.nvim" }, result.plugins.d.dependencies)
  end)

  it("keeps every entry of a dependencies list made of several strings", function()
    local result = spec.normalize { { "a/pick", dependencies = { "a/x", "a/y" } } }

    assert.are.same({ "pick", "x", "y" }, result.order)
    assert.are.same({ "x", "y" }, result.plugins.pick.dependencies)
  end)

  it("keeps every entry of a dependencies list mixing strings and spec tables", function()
    local result = spec.normalize { { "a/pick", dependencies = { "a/x", { "a/y", lazy = true }, "a/z" } } }

    assert.are.same({ "pick", "x", "y", "z" }, result.order)
    assert.are.same({ "x", "y", "z" }, result.plugins.pick.dependencies)
    assert.is_true(result.plugins.y.lazy)
  end)

  it("accepts a single spec table as dependencies and tolerates dependency cycles", function()
    local ts = { "x/treesitter" }
    local result = spec.normalize {
      { "x/treesitter", dependencies = { { "x/commentstring", dependencies = { ts } } } },
    }

    assert.are.same({ "commentstring" }, result.plugins.treesitter.dependencies)
    assert.are.same({ "treesitter" }, result.plugins.commentstring.dependencies)
  end)

  it("maps version, branch and short sources to vim.pack fields", function()
    local result = spec.normalize {
      { "saghen/blink.cmp", version = "v1.*" },
      { "x/treesitter", branch = "main", version = false },
      { "y/pinned", version = false },
    }

    assert.are.same({ range = "1.*" }, result.plugins["blink.cmp"].version)
    assert.are.equal("https://github.com/saghen/blink.cmp", result.plugins["blink.cmp"].src)
    assert.are.equal("main", result.plugins.treesitter.version)
    assert.is_nil(result.plugins.pinned.version)
  end)

  it("expands keys per mode and drops keys disabled with a false rhs", function()
    local result = spec.normalize {
      {
        "folke/flash.nvim",
        keys = { { "t", mode = { "n", "x" }, false }, { "S", mode = { "n", "x" }, "rhs", desc = "d" }, "<CR>" },
      },
    }

    local lhs = {}
    for _, key in ipairs(result.plugins["flash.nvim"].keys) do
      table.insert(lhs, key.mode .. ":" .. key.lhs)
    end
    assert.are.same({ "n:S", "x:S", "n:<CR>" }, lhs)
  end)

  it("raises on spec keys the loader does not implement", function()
    assert.has_error(function()
      spec.normalize { { "a/b", import = "x" } }
    end, "pack: unsupported spec key 'import' in a/b")
  end)

  it("raises on key fields the loader does not implement", function()
    assert.has_error(function()
      spec.normalize { { "a/b", keys = { { "x", ft = "lua" } } } }
    end, "pack: unsupported key field 'ft' in keys of a/b")
  end)

  it("requires an explicit main when setup is implied by opts or config=true", function()
    assert.has_error(function()
      spec.normalize { { "a/b", opts = {} } }
    end, "pack: b uses opts or config=true and needs an explicit `main`")
    assert.has_error(function()
      spec.normalize { { "a/c", config = true } }
    end, "pack: c uses opts or config=true and needs an explicit `main`")
    assert.has_no.errors(function()
      spec.normalize { { "a/d", opts = {}, config = function() end }, { "a/e", opts = {}, main = "e" } }
    end)
  end)
end)
