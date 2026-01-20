-- spec/lsp/formatter_selector_spec.lua
require "nvim.spec.spec_helper"

describe("lsp.formatter_selector", function()
  local formatter_selector

  before_each(function()
    -- Reset module cache
    package.loaded["lsp.formatter_selector"] = nil
    package.loaded["lsp.config"] = nil

    -- Mock lsp.config
    package.loaded["lsp.config"] = {
      formatters = {
        biome = {
          formatter_priority = {
            priority = 1,
            overrides = {
              prettier = true,
            },
          },
        },
        prettier = {
          formatter_priority = {
            priority = 2,
            overrides = {},
          },
        },
        eslint = {
          formatter_priority = {
            priority = 3,
            overrides = {},
          },
        },
        ["typescript-tools"] = {
          formatter_priority = {
            priority = 4,
            overrides = {},
          },
        },
      },
    }

    formatter_selector = require "lsp.formatter_selector"
  end)

  describe("get_formatter_priority", function()
    it("should return configured priority for biome", function()
      local priority = formatter_selector.get_formatter_priority "biome"
      assert.equals(1, priority)
    end)

    it("should return configured priority for prettier", function()
      local priority = formatter_selector.get_formatter_priority "prettier"
      assert.equals(2, priority)
    end)

    it("should return configured priority for eslint", function()
      local priority = formatter_selector.get_formatter_priority "eslint"
      assert.equals(3, priority)
    end)

    it("should return configured priority for typescript-tools", function()
      local priority = formatter_selector.get_formatter_priority "typescript-tools"
      assert.equals(4, priority)
    end)

    it("should return 99 for unknown formatters", function()
      local priority = formatter_selector.get_formatter_priority "unknown_formatter"
      assert.equals(99, priority)
    end)
  end)

  describe("should_format_with", function()
    it("should return true for formatters with priority config", function()
      local result = formatter_selector.should_format_with "biome"
      assert.is_true(result)
    end)

    it("should return true for prettier with priority config", function()
      local result = formatter_selector.should_format_with "prettier"
      assert.is_true(result)
    end)

    it("should return true for eslint with priority config", function()
      -- eslint has formatter_priority config, so should_format_with returns true
      local result = formatter_selector.should_format_with "eslint"
      assert.is_true(result)
    end)

    it("should return true for typescript-tools with priority config", function()
      -- typescript-tools has formatter_priority config, so should_format_with returns true
      local result = formatter_selector.should_format_with "typescript-tools"
      assert.is_true(result)
    end)

    it("should return true for unknown formatters", function()
      local result = formatter_selector.should_format_with "unknown_formatter"
      assert.is_true(result)
    end)
  end)

  describe("get_best_formatter", function()
    it("should be a function", function()
      assert.is_function(formatter_selector.get_best_formatter)
    end)

    it("should return nil when no formatters are available", function()
      -- Mock vim.lsp.get_clients to return empty array
      vim.lsp = {
        get_clients = function()
          return {}
        end,
      }

      local result = formatter_selector.get_best_formatter(1)
      assert.is_nil(result)
    end)

    it("should return client with highest priority", function()
      -- Create mock clients with supports_method
      local prettier_client = {
        name = "prettier",
        supports_method = function(_, method)
          return method == "textDocument/formatting"
        end,
      }
      local biome_client = {
        name = "biome",
        supports_method = function(_, method)
          return method == "textDocument/formatting"
        end,
      }
      local eslint_client = {
        name = "eslint",
        supports_method = function(_, method)
          return method == "textDocument/formatting"
        end,
      }

      -- Mock vim.lsp.get_clients to return multiple clients
      vim.lsp = {
        get_clients = function()
          return {
            prettier_client,
            biome_client,
            eslint_client,
          }
        end,
      }

      local result = formatter_selector.get_best_formatter(1)
      assert.is_not_nil(result)
      assert.equals("biome", result.name)
    end)

    it("should skip clients that don't support formatting", function()
      -- Create mock clients
      local lua_ls_client = {
        name = "lua_ls",
        supports_method = function(_, method)
          return method ~= "textDocument/formatting"
        end,
      }
      local prettier_client = {
        name = "prettier",
        supports_method = function(_, method)
          return method == "textDocument/formatting"
        end,
      }

      -- Mock vim.lsp.get_clients to return clients with mixed support
      vim.lsp = {
        get_clients = function()
          return {
            lua_ls_client,
            prettier_client,
          }
        end,
      }

      local result = formatter_selector.get_best_formatter(1)
      assert.is_not_nil(result)
      assert.equals("prettier", result.name)
    end)
  end)
end)
