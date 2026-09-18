-- spec/lsp/settings_factory_spec.lua
require "nvim.spec.spec_helper"

describe("lsp.settings_factory", function()
  local factory
  local mock_deps

  before_each(function()
    -- Reset module cache
    package.loaded["lsp.settings_factory"] = nil
    package.loaded["core.module_loader"] = nil
    package.loaded["lsp.config"] = nil
    package.loaded["core.utils"] = nil
    package.loaded["lsp.utils"] = nil

    -- Mock core.module_loader
    mock_deps = {
      ft = {
        js_project = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      core_utils = {
        has_config_files = function(config_files)
          return true
        end,
      },
      utils = {
        create_root_pattern = function(patterns)
          return function()
            return "/test/root"
          end
        end,
      },
      config = {
        formatters = {
          ["typescript-tools"] = {
            config_files = { "tsconfig.json", "jsconfig.json" },
          },
          eslint = {
            config_files = {
              ".eslintrc",
              ".eslintrc.json",
              "eslint.config.js",
            },
          },
        },
      },
      capabilities = {
        setup = function()
          return { test = "capabilities" }
        end,
      },
      handlers = {
        handlers = { test = "handlers" },
        on_attach = function() end,
      },
    }

    package.loaded["core.module_loader"] = {
      require_batch = function()
        return mock_deps
      end,
    }

    factory = require "lsp.settings_factory"
  end)

  describe("create_formatter_server", function()
    it("adds autostart function when config_files exist", function()
      local config = factory.create_formatter_server "eslint"

      assert.is_function(config.autostart)
      assert.is_true(config.autostart())
    end)

    it("adds root_dir function when config_files exist", function()
      local config = factory.create_formatter_server "eslint"

      assert.is_function(config.root_dir)
      assert.equals("/test/root", config.root_dir())
    end)

    it("merges overrides correctly", function()
      local config = factory.create_formatter_server("eslint", {
        filetypes = { "custom", "types" },
        settings = {
          eslint = {
            validate = true,
          },
        },
      })

      assert.same({ "custom", "types" }, config.filetypes)
      assert.is_true(config.settings.eslint.validate)
    end)

    it("disables hover for formatter-only servers", function()
      local config = factory.create_formatter_server "eslint"
      local mock_client = {
        server_capabilities = {
          hoverProvider = true,
        },
      }

      config.on_attach(mock_client, 1)

      assert.is_false(mock_client.server_capabilities.hoverProvider)
    end)
  end)

  describe("create_js_server", function()
    it("creates JS server config with default filetypes", function()
      local config = factory.create_js_server "typescript-tools"

      assert.is_not_nil(config)
      assert.same(mock_deps.ft.js_project, config.filetypes)
    end)
  end)

  describe("create_generic_server", function()
    it("creates generic server config with capabilities and handlers", function()
      local config = factory.create_generic_server()

      assert.is_not_nil(config.capabilities)
      assert.is_not_nil(config.handlers)
    end)

    it("merges overrides", function()
      local config = factory.create_generic_server {
        filetypes = { "lua" },
      }

      assert.same({ "lua" }, config.filetypes)
    end)
  end)

  describe("create_root_dir", function()
    it("creates root_dir function with config files", function()
      local root_dir = factory.create_root_dir { "config.js" }

      assert.is_function(root_dir)
      assert.equals("/test/root", root_dir())
    end)
  end)

  describe("get_filetypes", function()
    it("should return filetypes for known categories", function()
      local filetypes = factory.get_filetypes "js_project"

      assert.same(mock_deps.ft.js_project, filetypes)
    end)

    it("should return empty table for unknown categories", function()
      local filetypes = factory.get_filetypes "unknown"

      assert.same({}, filetypes)
    end)
  end)

  describe("check_deps", function()
    it("should return true when all deps are loaded", function()
      assert.is_true(factory.check_deps())
    end)
  end)
end)
