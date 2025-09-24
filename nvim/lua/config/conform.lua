-- Conform.nvim configuration for lightweight formatting
local utils = require "core.utils"
local lsp_config = require "lsp.config"
local util = require "conform.util"

require("conform").setup {
  formatters_by_ft = {
    javascript = { "eslint_d", "biome", "prettier" },
    javascriptreact = { "eslint_d", "biome", "prettier" },
    typescript = { "eslint_d", "biome", "prettier" },
    typescriptreact = { "eslint_d", "biome", "prettier" },
    vue = { "biome", "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    html = { "prettier" },
    json = { "biome", "prettier" },
    jsonc = { "biome", "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    graphql = { "prettier" },
    handlebars = { "prettier" },

    lua = { "stylua" },
    python = { "ruff_format", "ruff_fix" },
    go = { "gofmt", "goimports" },
    rust = { "rustfmt" },
    toml = { "taplo" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    zsh = { "shfmt" },

    -- Add more as needed
    ["*"] = { "trim_whitespace" },
  },

  -- Formatter selection strategy
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end

    return {
      timeout_ms = 3000,
      lsp_fallback = true, -- Use LSP formatting as fallback
    }
  end,

  -- Custom formatters using centralized config from lsp.config
  formatters = {
    -- ESLint_d formatter with best practices from o3 research
    eslint_d = {
      -- Use project-local binary if it exists
      command = util.from_node_modules "eslint_d",
      -- Allow exit code 1 (lint errors fixed) so Conform doesn't treat it as failure
      exit_codes = { 0, 1 },
      -- Recognize monorepo roots using centralized config
      cwd = util.root_file(vim.list_extend(lsp_config.formatters.eslint.config_files, { "package.json", ".git" })),
      -- Optional extra flags for performance
      prepend_args = { "--cache" },
      env = { ESLINT_USE_FLAT_CONFIG = "true" },
    },

    -- Biome formatter with config detection from lsp.config
    biome = {
      condition = function(_, ctx)
        local config_files = lsp_config.formatters.biome.config_files
        return utils.has_config_files(config_files, ctx.dirname)
      end,
    },

    -- Prettier formatter with fallback when no config files
    prettier = {
      command = "prettier", -- Use system prettier (mise-managed)
      condition = function(_, ctx)
        local config_files = lsp_config.formatters.prettier.config_files
        -- Always allow prettier as fallback, even without config files
        return utils.has_config_files(config_files, ctx.dirname)
          or not utils.has_config_files(lsp_config.formatters.biome.config_files, ctx.dirname)
      end,
    },
  },

  -- Logging for debugging
  log_level = vim.log.levels.WARN,
  notify_on_error = true,
}

-- Auto-format disable/enable commands
vim.api.nvim_create_user_command("AutoFormatDisable", function(args)
  if args.bang then
    -- AutoFormatDisable! will disable formatting globally
    vim.g.disable_autoformat = true
  else
    -- AutoFormatDisable will disable formatting for current buffer
    vim.b.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat on save",
  bang = true,
})

vim.api.nvim_create_user_command("AutoFormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat on save",
})

-- Status function for debugging
local function get_format_status()
  local conform = require "conform"
  local formatters = conform.list_formatters(0)

  if #formatters == 0 then return "No formatters available" end

  local available = {}
  for _, formatter in ipairs(formatters) do
    if formatter.available then table.insert(available, formatter.name) end
  end

  return "Available: " .. table.concat(available, ", ")
end

-- Debug command
vim.api.nvim_create_user_command("ConformInfo", function()
  vim.notify(get_format_status(), vim.log.levels.INFO)
end, { desc = "Show conform formatter info" })
