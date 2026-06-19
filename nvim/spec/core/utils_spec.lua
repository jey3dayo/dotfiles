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
    it("should return module when it exists", function()
      local result = utils.safe_require "core.utils"
      assert.is_not_nil(result)
    end)

    it("should return nil when module does not exist", function()
      local result = utils.safe_require "nonexistent.module"
      assert.is_nil(result)
    end)
  end)

  describe("has_config_files", function()
    it("should be a function", function()
      assert.is_function(utils.has_config_files)
    end)

    it("should accept config_files and dirname parameters", function()
      -- Mock vim.fn functions
      vim.fn.filereadable = function()
        return 0
      end
      vim.fn.fnamemodify = function(path, modifier)
        if modifier == ":h" then
          local parent = path:match "(.+)/"
          return parent or path
        end
        return path
      end

      local result = utils.has_config_files({ "config.js" }, "/tmp")
      assert.is_boolean(result)
    end)
  end)

  describe("api shortcuts", function()
    it("should expose autocmd", function()
      assert.is_not_nil(utils.autocmd)
    end)

    it("should expose augroup", function()
      assert.is_not_nil(utils.augroup)
    end)

    it("should expose user_command", function()
      assert.is_not_nil(utils.user_command)
    end)
  end)
end)
