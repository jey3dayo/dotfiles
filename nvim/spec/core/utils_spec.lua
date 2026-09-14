-- spec/core/utils_spec.lua
require "nvim.spec.spec_helper"

describe("core.utils", function()
  local utils

  before_each(function()
    -- Reset module cache
    package.loaded["core.utils"] = nil
    utils = require "core.utils"
  end)

  describe("safe_require", function()
    it("returns the module when it exists", function()
      assert.is_not_nil(utils.safe_require "core.utils")
    end)

    it("returns nil when the module does not exist", function()
      assert.is_nil(utils.safe_require "nonexistent.module")
    end)
  end)

  describe("has_config_files", function()
    local original_filereadable

    before_each(function()
      original_filereadable = vim.fn.filereadable
      vim.fn.fnamemodify = function(path, _modifier)
        return path:match "(.+)/" or path
      end
    end)

    after_each(function()
      vim.fn.filereadable = original_filereadable
    end)

    it("returns false when no config file is readable", function()
      vim.fn.filereadable = function()
        return 0
      end

      assert.is_false(utils.has_config_files({ "config.js" }, "/tmp"))
    end)

    it("returns true when a config file is readable", function()
      vim.fn.filereadable = function()
        return 1
      end

      assert.is_true(utils.has_config_files({ "config.js" }, "/tmp"))
    end)
  end)
end)
