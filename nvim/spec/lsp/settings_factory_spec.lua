-- spec/lsp/settings_factory_spec.lua
require "spec.spec_helper"

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
        tailwind_supported = { "html", "css", "javascriptreact", "typescriptreact" },
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
          tailwindcss = {
            config_files = {
              "tailwind.config.js",
              "tailwind.config.cjs",
              "tailwind.config.ts",
            },
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
    it("should create basic formatter server config", function()
      local config = factory.create_formatter_server "tailwindcss"

      assert.is_not_nil(config)
      assert.is_not_nil(config.capabilities)
      assert.is_function(config.on_attach)
    end)

    it("should add autostart function when config_files exist", function()
      local config = factory.create_formatter_server "tailwindcss"

      assert.is_function(config.autostart)
      assert.is_true(config.autostart())
    end)

    it("should add root_dir function when config_files exist", function()
      local config = factory.create_formatter_server "tailwindcss"

      assert.is_function(config.root_dir)
      assert.equals("/test/root", config.root_dir())
    end)

    it("should merge overrides correctly", function()
      local config = factory.create_formatter_server("tailwindcss", {
        filetypes = { "custom", "types" },
        settings = {
          tailwindCSS = {
            validate = true,
          },
        },
      })

      assert.same({ "custom", "types" }, config.filetypes)
      assert.is_true(config.settings.tailwindCSS.validate)
    end)

    it("should disable hover for formatter-only servers", function()
      local config = factory.create_formatter_server "tailwindcss"
      local mock_client = {
        server_capabilities = {
          hoverProvider = true,
        },
      }

      config.on_attach(mock_client, 1)

      assert.is_false(mock_client.server_capabilities.hoverProvider)
    end)

    it("should work for eslint formatter", function()
      local config = factory.create_formatter_server "eslint"

      assert.is_function(config.autostart)
      assert.is_function(config.root_dir)
      assert.is_true(config.autostart())
    end)
  end)

  describe("create_js_server", function()
    it("should create JS server config with default filetypes", function()
      local config = factory.create_js_server "typescript-tools"

      assert.is_not_nil(config)
      assert.same(mock_deps.ft.js_project, config.filetypes)
    end)

    it("should add root_dir for servers with config_files", function()
      local config = factory.create_js_server "typescript-tools"

      -- typescript-tools should have root_dir if formatters config exists
      assert.is_not_nil(config.root_dir)
    end)
  end)

  describe("create_generic_server", function()
    it("should create generic server config", function()
      local config = factory.create_generic_server()

      assert.is_not_nil(config)
      assert.is_not_nil(config.capabilities)
      assert.is_not_nil(config.handlers)
    end)

    it("should merge overrides", function()
      local config = factory.create_generic_server {
        filetypes = { "lua" },
      }

      assert.same({ "lua" }, config.filetypes)
    end)
  end)

  describe("create_root_dir", function()
    it("should create root_dir function with config files", function()
      local root_dir = factory.create_root_dir({ "config.js" })

      assert.is_function(root_dir)
      assert.equals("/test/root", root_dir())
    end)

    it("should add fallback files", function()
      local root_dir = factory.create_root_dir({ "config.js" }, { "fallback.json" })

      assert.is_function(root_dir)
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
