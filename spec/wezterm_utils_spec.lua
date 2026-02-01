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

  describe("split_from_url", function()
    it("should extract hostname and path from ssh url", function()
      local host, path = utils.split_from_url "ssh://user@example.com/home/user/project"
      assert.are.equal("example", host)
      assert.are.equal("project", path)
    end)

    it("should handle plain file paths", function()
      local host, path = utils.split_from_url "/Users/example/workspace"
      assert.are.equal("", host)
      assert.are.equal("workspace", path)
    end)
  end)

  describe("tab_title_from_pane", function()
    it("should prioritize foreground process name", function()
      local title = utils.tab_title_from_pane({ foreground_process_name = "/usr/bin/bash" }, 12)
      assert.are.equal("bash", title)
    end)

    it("should include hostname when cwd is remote", function()
      local pane = { current_working_dir = "ssh://user@my-host.example.com/home/user/project" }
      local title = utils.tab_title_from_pane(pane, 24)
      assert.are.equal("my-host:project", title)
    end)

    it("should fall back to default title", function()
      local title = utils.tab_title_from_pane(nil, nil)
      assert.are.equal("wezterm", title)
    end)
  end)

  describe("abbreviate_home_dir", function()
    it("should abbreviate home directory to ~", function()
      local home = os.getenv "HOME" or os.getenv "USERPROFILE"
      if home then
        assert.are.equal("~", utils.abbreviate_home_dir(home))
        assert.are.equal("~/Documents", utils.abbreviate_home_dir(home .. "/Documents"))
      end
    end)

    it("should not abbreviate non-home paths", function()
      assert.are.equal("/usr/local", utils.abbreviate_home_dir "/usr/local")
    end)
  end)

  describe("exists", function()
    it("should find element in array", function()
      assert.is_true(utils.exists({ 1, 2, 3 }, 2))
      assert.is_false(utils.exists({ 1, 2, 3 }, 4))
    end)

    it("should find element in nested tables", function()
      assert.is_true(utils.exists({ 1, { 2, 3 } }, 3))
    end)
  end)

  describe("convert_useful_path", function()
    it("should convert and extract basename", function()
      local result = utils.convert_useful_path "~/workspace/project"
      assert.are.equal("project", result)
    end)
  end)

  describe("font_with_fallback", function()
    pending("requires wezterm runtime and constants module", function()
      -- This function requires:
      -- 1. wezterm.font_with_fallback API
      -- 2. constants module with font.fallbacks configuration
      -- Should be tested in integration tests with actual wezterm runtime
      local font = utils.font_with_fallback("UDEV Gothic 35NFLG", { weight = "Bold" })
      assert.is_not_nil(font)
      assert.is_table(font.names)
      assert.is_true(#font.names > 1)
    end)
  end)
end)
