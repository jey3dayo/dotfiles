-- spec/lsp/settings/tailwindcss_spec.lua
require "nvim.spec.spec_helper"

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

  it("has correct filetypes", function()
    assert.same({ "html", "css", "javascriptreact", "typescriptreact", "vue" }, tailwindcss_config.filetypes)
  end)

  it("has autostart function", function()
    assert.is_function(tailwindcss_config.autostart)
    assert.is_true(tailwindcss_config.autostart())
  end)

  it("has root_dir function", function()
    assert.is_function(tailwindcss_config.root_dir)
    assert.equals("/test/tailwind/root", tailwindcss_config.root_dir())
  end)

  it("maps nonstandard filetypes in init_options.includeLanguages", function()
    local include = tailwindcss_config.init_options.includeLanguages

    assert.equals("erb", include.eruby)
    assert.equals("html-eex", include.eelixir)
    assert.equals("javascriptreact", include["javascript.jsx"])
  end)

  it("enables validation in tailwindCSS settings", function()
    assert.is_true(tailwindcss_config.settings.tailwindCSS.validate)
  end)

  describe("on_attach", function()
    it("calls handlers.on_attach", function()
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

    it("sets client.config.trace to 'off'", function()
      local mock_client = {
        config = {},
      }
      tailwindcss_config.on_attach(mock_client, 1)

      assert.equals("off", mock_client.config.trace)
    end)
  end)
end)
