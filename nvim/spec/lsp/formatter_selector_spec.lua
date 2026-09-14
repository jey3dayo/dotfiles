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
    it("returns the configured priority", function()
      assert.equals(1, formatter_selector.get_formatter_priority "biome")
      assert.equals(2, formatter_selector.get_formatter_priority "prettier")
    end)

    it("returns 99 for unknown formatters", function()
      assert.equals(99, formatter_selector.get_formatter_priority "unknown_formatter")
    end)
  end)

  describe("should_format_with", function()
    it("returns true when priority config exists or is unknown", function()
      assert.is_true(formatter_selector.should_format_with "biome")
      assert.is_true(formatter_selector.should_format_with "unknown_formatter")
    end)
  end)

  describe("get_best_formatter", function()
    it("returns nil when no formatters are available", function()
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
