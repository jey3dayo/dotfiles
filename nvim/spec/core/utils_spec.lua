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

  describe("find_command", function()
    it("should return first existing path", function()
      -- Create a temporary file
      local tmpfile = os.tmpname()
      local file = io.open(tmpfile, "w")
      file:write "test"
      file:close()

      local result = utils.find_command { "/nonexistent/path", tmpfile }
      assert.equals(tmpfile, result)

      -- Clean up
      os.remove(tmpfile)
    end)

    it("should return nil when no paths exist", function()
      local result = utils.find_command { "/nonexistent/path1", "/nonexistent/path2" }
      assert.is_nil(result)
    end)

    it("should return nil for empty paths", function()
      local result = utils.find_command {}
      assert.is_nil(result)
    end)
  end)

  describe("check_file_exists", function()
    it("should be a function", function()
      assert.is_function(utils.check_file_exists)
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
