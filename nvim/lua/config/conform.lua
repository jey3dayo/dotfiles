-- Conform.nvim configuration for lightweight formatting
local utils = require "core.utils"
local autoformat = require "lsp.autoformat"
local lsp_config = require "lsp.config"
local util = require "conform.util"

local function has_biome_config(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  local dirname = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
  return utils.has_config_files(lsp_config.formatters.biome.config_files, dirname)
end

local function js_like_formatters(bufnr)
  local formatters = { "eslint_d", "prettier" }
  if has_biome_config(bufnr) then table.insert(formatters, 2, "biome") end
  return formatters
end

local function json_like_formatters(bufnr)
  local formatters = { "prettier" }
  if has_biome_config(bufnr) then table.insert(formatters, 1, "biome") end
  return formatters
end

require("conform").setup {
  formatters_by_ft = {
    javascript = js_like_formatters,
    javascriptreact = js_like_formatters,
    typescript = js_like_formatters,
    typescriptreact = js_like_formatters,
    vue = json_like_formatters,
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    html = { "prettier" },
    json = json_like_formatters,
    jsonc = json_like_formatters,
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
    -- Respect centralized autoformat flags
    if not autoformat.is_enabled(bufnr) then return end

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

    -- Prettier formatter with fallback when no config files
    prettier = {
      -- Use mise shim, fallback handled by PATH
      command = "prettier",
      -- Always enable prettier
      condition = function(_, _)
        return true
      end,
    },
  },

  -- Logging for debugging
  log_level = vim.log.levels.WARN,
  notify_on_error = true,
}

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
