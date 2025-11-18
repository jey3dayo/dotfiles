local utils = require "wezterm.utils"

describe("wezterm utils", function()
  describe("basename", function()
    it("should extract filename from path", function()
      assert.are.equal("file.txt", utils.basename "/path/to/file.txt")
      assert.are.equal("file.txt", utils.basename "file.txt")
      assert.are.equal("", utils.basename "/path/to/")
    end)
  end)

  describe("truncate_right", function()
    it("should truncate string from right when over limit", function()
      assert.are.equal("hello...", utils.truncate_right("hello world", 8))
      assert.are.equal("short", utils.truncate_right("short", 10))
      assert.are.equal("", utils.truncate_right("", 5))
    end)
  end)

  describe("merge_tables", function()
    it("should merge two tables", function()
      local t1 = { a = 1, b = 2 }
      local t2 = { c = 3, d = 4 }
      local result = utils.merge_tables(t1, t2)

      assert.are.equal(1, result.a)
      assert.are.equal(2, result.b)
      assert.are.equal(3, result.c)
      assert.are.equal(4, result.d)
    end)

    it("should override values from first table", function()
      local t1 = { a = 1, b = 2 }
      local t2 = { a = 3, c = 4 }
      local result = utils.merge_tables(t1, t2)

      assert.are.equal(3, result.a)
      assert.are.equal(2, result.b)
      assert.are.equal(4, result.c)
    end)
  end)

  describe("merge_lists", function()
    it("should concatenate two arrays", function()
      local list1 = { 1, 2, 3 }
      local list2 = { 4, 5, 6 }
      local result = utils.merge_lists(list1, list2)

      assert.are.same({ 1, 2, 3, 4, 5, 6 }, result)
    end)
  end)

  describe("array_concat", function()
    it("should concatenate multiple arrays", function()
      local arr1 = { 1, 2 }
      local arr2 = { 3, 4 }
      local arr3 = { 5, 6 }
      local result = utils.array_concat(arr1, arr2, arr3)

      assert.are.same({ 1, 2, 3, 4, 5, 6 }, result)
    end)
  end)

  describe("convert_home_dir", function()
    it("should convert ~ to home directory", function()
      local home = os.getenv "HOME" or os.getenv "USERPROFILE"
      if home then
        local result = utils.convert_home_dir "~/Documents"
        assert.are.equal(home .. "/Documents", result)
      end
    end)

    it("should return path unchanged if no ~ prefix", function()
      assert.are.equal("/absolute/path", utils.convert_home_dir "/absolute/path")
      assert.are.equal("relative/path", utils.convert_home_dir "relative/path")
    end)
  end)

  describe("file_exists", function()
    it("should return false for non-existent file", function()
      assert.is_false(utils.file_exists "/non/existent/file.txt")
    end)
  end)
end)
