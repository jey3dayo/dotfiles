-- Conform.nvim setup
local utils = require "core.utils"
local mise = require "core.mise"
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

local function command_exists(cmd)
  return vim.fn.executable(mise.resolve_command(cmd)) > 0
end

local function format_with_prettier_or_biome(bufnr)
  if has_prettier_config(bufnr) and command_exists "prettier" then return { "prettier", stop_after_first = true } end
  if has_biome_config(bufnr) and command_exists "biome" then return { "biome", stop_after_first = true } end

  if command_exists "biome" then
    return { "biome", stop_after_first = true }
  elseif command_exists "prettier" then
    return { "prettier", stop_after_first = true }
  end

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
    ["yaml.docker-compose"] = { "prettier" },
    ["yaml.gitlab"] = { "prettier" },
    ["yaml.helm-values"] = { "prettier" },
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
    ["*"] = { "trim_whitespace" },
  },
  format_on_save = function(bufnr)
    if not autoformat.is_enabled(bufnr) then return end

    return {
      timeout_ms = 3000,
      lsp_fallback = true,
    }
  end,
  formatters = {
    eslint_d = {
      command = util.find_executable({ "node_modules/.bin/eslint_d", mise.resolve_command "eslint_d" }, "eslint_d"),
      exit_codes = { 0, 1 },
      condition = function(_, ctx)
        return has_eslint_config(ctx and ctx.dirname or nil)
      end,
      cwd = util.root_file(vim.list_extend(lsp_config.formatters.eslint.config_files, { "package.json", ".git" })),
      prepend_args = { "--cache" },
      env = { ESLINT_USE_FLAT_CONFIG = "true" },
    },
    prettier = {
      command = mise.resolve_command "prettier",
      condition = function()
        return command_exists "prettier"
      end,
    },
    biome = {
      command = mise.resolve_command "biome",
      condition = function()
        return command_exists "biome"
      end,
    },
    stylua = {
      command = mise.resolve_command "stylua",
    },
  },
  log_level = vim.log.levels.WARN,
  notify_on_error = true,
}

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

vim.api.nvim_create_user_command("ConformInfo", function()
  vim.notify(get_format_status(), vim.log.levels.INFO)
end, { desc = "Show conform formatter info" })
