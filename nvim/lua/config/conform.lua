-- Conform.nvim configuration for lightweight formatting
local utils = require "core.utils"
local autoformat = require "lsp.autoformat"
local lsp_config = require "lsp.config"
local util = require "conform.util"

local function resolve_dir(target)
  if type(target) == "string" then return target end
  local name = vim.api.nvim_buf_get_name(target or 0)
  return name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
end

local function has_formatter_config(formatter, target)
  local config = lsp_config.formatters[formatter]
  if not (config and config.config_files) then return false end
  return utils.has_config_files(config.config_files, resolve_dir(target))
end

local function has_eslint_config(target)
  return has_formatter_config("eslint", target)
end

local function has_biome_config(target)
  return has_formatter_config("biome", target)
end

local function has_prettier_config(target)
  return has_formatter_config("prettier", target)
end

-- Check if a command is available in PATH
local function command_exists(cmd)
  return vim.fn.executable(cmd) > 0
end

local function format_with_prettier_or_biome(bufnr)
  -- Prefer Prettier when config file exists and command is available
  if has_prettier_config(bufnr) and command_exists("prettier") then
    return { "prettier", stop_after_first = true }
  end

  -- Fallback to Biome when config exists and command is available
  if has_biome_config(bufnr) and command_exists("biome") then
    return { "biome", stop_after_first = true }
  end

  -- Final fallback: prefer Biome if available, otherwise Prettier
  if command_exists("biome") then
    return { "biome", stop_after_first = true }
  elseif command_exists("prettier") then
    return { "prettier", stop_after_first = true }
  end

  -- No formatter available - return empty to avoid errors
  return {}
end

local js_like_formatters = format_with_prettier_or_biome
local json_like_formatters = format_with_prettier_or_biome

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
      -- Only use ESLint formatter when a config exists
      condition = function(_, ctx)
        return has_eslint_config(ctx and ctx.dirname or nil)
      end,
      -- Recognize monorepo roots using centralized config
      cwd = util.root_file(vim.list_extend(lsp_config.formatters.eslint.config_files, { "package.json", ".git" })),
      -- Optional extra flags for performance
      prepend_args = { "--cache" },
      env = { ESLINT_USE_FLAT_CONFIG = "true" },
    },

    -- Prettier formatter with command availability check
    prettier = {
      -- Use mise shim, fallback handled by PATH
      command = "prettier",
      -- Only enable when prettier command is available
      condition = function(_, _)
        return command_exists("prettier")
      end,
    },

    -- Biome formatter with command availability check
    biome = {
      -- Use mise shim, fallback handled by PATH
      command = "biome",
      -- Only enable when biome command is available
      condition = function(_, _)
        return command_exists("biome")
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
