-- spec/lsp/utils_spec.lua
require "nvim.spec.spec_helper"

describe("lsp.utils", function()
  local lsp_utils

  before_each(function()
    -- Reset module cache
    package.loaded["lsp.utils"] = nil
    package.loaded["lspconfig.util"] = nil

    -- Mock lspconfig.util
    package.loaded["lspconfig.util"] = {
      root_pattern = function(...)
        local patterns = { ... }
        return function(fname)
          -- Simple mock: return directory if any pattern matches
          for _, pattern in ipairs(patterns) do
            if fname:match(pattern) then return fname:match "(.+)/" or fname end
          end
          return nil
        end
      end,
    }

    lsp_utils = require "lsp.utils"
  end)

  describe("create_root_pattern", function()
    it("should be a function", function()
      assert.is_function(lsp_utils.create_root_pattern)
    end)

    it("should return a function", function()
      local root_pattern_fn = lsp_utils.create_root_pattern { "package.json" }
      assert.is_function(root_pattern_fn)
    end)

    it("should create pattern function that matches files", function()
      local root_pattern_fn = lsp_utils.create_root_pattern { "package.json", "tsconfig.json" }

      local result = root_pattern_fn "/path/to/project/package.json"
      assert.is_not_nil(result)
      assert.equals("/path/to/project", result)
    end)

    it("should handle multiple patterns", function()
      local root_pattern_fn = lsp_utils.create_root_pattern { ".git", "package.json" }

      local result1 = root_pattern_fn "/path/to/project/.git"
      assert.is_not_nil(result1)

      local result2 = root_pattern_fn "/path/to/project/package.json"
      assert.is_not_nil(result2)
    end)

    it("should return nil when no pattern matches", function()
      local root_pattern_fn = lsp_utils.create_root_pattern { "package.json" }

      local result = root_pattern_fn "/path/to/file.txt"
      assert.is_nil(result)
    end)
  end)

  describe("get_mason_package_path", function()
    it("should be a function", function()
      assert.is_function(lsp_utils.get_mason_package_path)
    end)

    it("should return nil when mason-registry is not available", function()
      -- Reset mason-registry mock
      package.loaded["mason-registry"] = nil

      local result = lsp_utils.get_mason_package_path("typescript-language-server")
      assert.is_nil(result)
    end)

    it("should return nil for non-existent package", function()
      -- Mock mason-registry
      package.loaded["mason-registry"] = {
        get_package = function(name)
          error "Package not found"
        end,
      }

      local result = lsp_utils.get_mason_package_path "non-existent-package"
      assert.is_nil(result)
    end)

    it("should return base path when no relative_path is provided", function()
      -- Mock mason-registry with a valid package
      package.loaded["mason-registry"] = {
        get_package = function(name)
          return {
            is_installed = function()
              return true
            end,
            get_install_path = function()
              return "/path/to/mason/packages/typescript-language-server"
            end,
          }
        end,
      }

      -- Mock vim.loop.fs_stat
      vim.loop = {
        fs_stat = function(path)
          return { type = "directory" }
        end,
      }

      -- Mock vim.fs.joinpath
      vim.fs = {
        joinpath = function(...)
          local parts = { ... }
          return table.concat(parts, "/")
        end,
      }

      local result = lsp_utils.get_mason_package_path "typescript-language-server"
      assert.equals("/path/to/mason/packages/typescript-language-server", result)
    end)

    it("should return full path when relative_path is provided and exists", function()
      -- Mock mason-registry
      package.loaded["mason-registry"] = {
        get_package = function(name)
          return {
            is_installed = function()
              return true
            end,
            get_install_path = function()
              return "/path/to/mason/packages/pkg"
            end,
          }
        end,
      }

      -- Mock vim.loop.fs_stat to return valid stat
      vim.loop = {
        fs_stat = function(path)
          if path:match "bin/cmd" then return { type = "file" } end
          return nil
        end,
      }

      -- Mock vim.fs.joinpath
      vim.fs = {
        joinpath = function(...)
          local parts = { ... }
          return table.concat(parts, "/")
        end,
      }

      local result = lsp_utils.get_mason_package_path("pkg", "bin/cmd")
      assert.equals("/path/to/mason/packages/pkg/bin/cmd", result)
    end)

    it("should return nil when relative_path does not exist", function()
      -- Mock mason-registry
      package.loaded["mason-registry"] = {
        get_package = function(name)
          return {
            is_installed = function()
              return true
            end,
            get_install_path = function()
              return "/path/to/mason/packages/pkg"
            end,
          }
        end,
      }

      -- Mock vim.loop.fs_stat to return nil (path doesn't exist)
      vim.loop = {
        fs_stat = function(path)
          return nil
        end,
      }

      -- Mock vim.fs.joinpath
      vim.fs = {
        joinpath = function(...)
          local parts = { ... }
          return table.concat(parts, "/")
        end,
      }

      local result = lsp_utils.get_mason_package_path("pkg", "nonexistent/path")
      assert.is_nil(result)
    end)
  end)
end)
