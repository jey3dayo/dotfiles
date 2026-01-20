-- spec/lsp/settings/tailwindcss_spec.lua
require "spec.spec_helper"

describe("lsp.settings.tailwindcss", function()
  local tailwindcss_config

  before_each(function()
    -- Reset module cache
    package.loaded["lsp.settings.tailwindcss"] = nil
    package.loaded["lsp.settings_factory"] = nil
    package.loaded["core.module_loader"] = nil
    package.loaded["core.filetypes"] = nil
    package.loaded["lsp.config"] = nil
    package.loaded["lsp.handlers"] = nil

    -- Mock dependencies
    package.loaded["core.filetypes"] = {
      tailwind_supported = { "html", "css", "javascriptreact", "typescriptreact", "vue" },
    }

    package.loaded["core.module_loader"] = {
      require_batch = function()
        return {
          ft = require "core.filetypes",
          core_utils = {
            has_config_files = function()
              return true
            end,
          },
          utils = {
            create_root_pattern = function(patterns)
              return function()
                return "/test/tailwind/root"
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
                  "postcss.config.js",
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
            handlers = {},
            on_attach = function() end,
          },
        }
      end,
    }

    package.loaded["lsp.handlers"] = {
      on_attach = function() end,
    }

    tailwindcss_config = require "lsp.settings.tailwindcss"
  end)

  it("should use factory.create_formatter_server", function()
    assert.is_not_nil(tailwindcss_config)
  end)

  it("should have correct filetypes", function()
    assert.same(
      { "html", "css", "javascriptreact", "typescriptreact", "vue" },
      tailwindcss_config.filetypes
    )
  end)

  it("should have autostart function", function()
    assert.is_function(tailwindcss_config.autostart)
    assert.is_true(tailwindcss_config.autostart())
  end)

  it("should have root_dir function", function()
    assert.is_function(tailwindcss_config.root_dir)
    assert.equals("/test/tailwind/root", tailwindcss_config.root_dir())
  end)

  it("should have init_options with includeLanguages", function()
    assert.is_not_nil(tailwindcss_config.init_options)
    assert.is_not_nil(tailwindcss_config.init_options.includeLanguages)
    assert.equals("erb", tailwindcss_config.init_options.includeLanguages.eruby)
    assert.equals("html-eex", tailwindcss_config.init_options.includeLanguages.eelixir)
    assert.equals("javascriptreact", tailwindcss_config.init_options.includeLanguages["javascript.jsx"])
  end)

  it("should have tailwindCSS settings", function()
    assert.is_not_nil(tailwindcss_config.settings)
    assert.is_not_nil(tailwindcss_config.settings.tailwindCSS)
    assert.is_true(tailwindcss_config.settings.tailwindCSS.validate)
  end)

  it("should have lint configuration", function()
    local lint = tailwindcss_config.settings.tailwindCSS.lint
    assert.is_not_nil(lint)
    assert.equals("warning", lint.cssConflict)
    assert.equals("error", lint.invalidApply)
    assert.equals("off", lint.invalidConfigPath)
    assert.equals("error", lint.invalidScreen)
    assert.equals("error", lint.invalidTailwindDirective)
    assert.equals("error", lint.invalidVariant)
    assert.is_false(lint.recommendedVariantOrder)
  end)

  it("should have experimental classRegex patterns", function()
    local experimental = tailwindcss_config.settings.tailwindCSS.experimental
    assert.is_not_nil(experimental)
    assert.is_not_nil(experimental.classRegex)
    assert.is_table(experimental.classRegex)
    assert.equals(4, #experimental.classRegex)
  end)

  describe("on_attach", function()
    it("should be a function", function()
      assert.is_function(tailwindcss_config.on_attach)
    end)

    it("should call handlers.on_attach", function()
      local handlers_on_attach_called = false
      package.loaded["lsp.handlers"] = {
        on_attach = function()
          handlers_on_attach_called = true
        end,
      }

      -- Reload config to use new handler
      package.loaded["lsp.settings.tailwindcss"] = nil
      tailwindcss_config = require "lsp.settings.tailwindcss"

      local mock_client = {
        config = {},
      }
      tailwindcss_config.on_attach(mock_client, 1)

      assert.is_true(handlers_on_attach_called)
    end)

    it("should set client.config.trace to 'off'", function()
      local mock_client = {
        config = {},
      }
      tailwindcss_config.on_attach(mock_client, 1)

      assert.equals("off", mock_client.config.trace)
    end)
  end)

  describe("capabilities", function()
    it("should have capabilities from factory", function()
      assert.is_not_nil(tailwindcss_config.capabilities)
    end)
  end)
end)
