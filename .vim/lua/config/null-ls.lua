local status, null_ls = pcall(require, "null-ls")
if not status then
  return
end

local status2, mason_null_ls = pcall(require, "mason-null-ls")
if not status2 then
  return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

mason_null_ls.setup {
  ensure_installed = require("lsp.config").null_ls_ensure_installed,
  automatic_installation = true,
  automatic_setup = false,
  handlers = {
    prettier = function()
      null_ls.register(formatting.prettier.with {
        condition = function(utils)
          return utils.has_file { "prettier.config.*", ".prettierrc", ".prettierrc.js" }
        end,
        prefer_local = "node_modules/.bin",
      })
    end,

    eslint = function()
      null_ls.register(diagnostics.eslint.with {
        condition = function(utils)
          return utils.has_file { ".eslintrc.json", ".eslintrc", ".eslintrc.js" }
        end,
        prefer_local = "node_modules/.bin",
        extra_filetypes = { "svelte" },
      })
    end,

    sql_formatter = function()
      null_ls.register(formatting.sql_formatter.with {
        extra_filetypes = { "pgsql" },
        args = function(params)
          local config_path = params.cwd .. "/.sql-formatter.json"
          if vim.loop.fs_stat(config_path) then
            return { "--config", config_path }
          end
          return { "--language", "postgresql" }
        end,
      })
    end,
  },
}

null_ls.setup {}
