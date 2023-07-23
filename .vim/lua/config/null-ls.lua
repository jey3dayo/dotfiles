local status, null_ls = pcall(require, "null-ls")
if not status then
  return
end

local status2, mason_null_ls = pcall(require, "mason-null-ls")
if not status2 then
  return
end

local clear_autocmds = require("autocmds").clear_autocmds
local autocmd = require("autocmds").autocmd
local augroup = require("autocmds").augroup

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local group = augroup("lsp_format_on_save", { clear = false })
local event = "BufWritePre" -- or "BufWritePost"
local async = event == "BufWritePost"

null_ls.setup {
  debug = false,
  sources = {
    formatting.stylua,
    diagnostics.luacheck.with {
      extra_args = { "--globals", "vim", "--globals", "awesome" },
    },
    formatting.prettier.with {
      condition = function(utils)
        return utils.has_file { "prettier.config.*", ".prettierrc", ".prettierrc.js" }
      end,
      prefer_local = "node_modules/.bin",
    },
    -- formatting.eslint.with {
    diagnostics.eslint.with {
      condition = function(utils)
        return utils.has_file { ".eslintrc.json", ".eslintrc", ".eslintrc.js" }
      end,
      prefer_local = "node_modules/.bin",
    },
    diagnostics.shellcheck,
    diagnostics.eslint,
    diagnostics.yamllint,
    diagnostics.rubocop.with {
      prefer_local = "bundle_bin",
      condition = function(utils)
        return utils.root_has_file { ".rubocop.yml" }
      end,
    },
    formatting.rubocop.with {
      prefer_local = "bundle_bin",
      condition = function(utils)
        return utils.root_has_file { ".rubocop.yml" }
      end,
    },
  },
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      -- format on save
      clear_autocmds { buffer = bufnr, group = group }
      autocmd(event, {
        buffer = bufnr,
        group = group,
        callback = function()
          vim.lsp.buf.format { bufnr = bufnr, async = async, timeout_ms = 5000 }
        end,
        desc = "[lsp] format on save",
      })
    end
  end,
}

mason_null_ls.setup {
  ensure_installed = nil,
  automatic_installation = true,
  automatic_setup = false,
}
