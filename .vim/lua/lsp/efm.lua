local utils = require("core.utils")
local with = utils.with
local extend = utils.extend
local formatter_settings = require("lsp.config").formatters

local M = {}

-- フォーマッターとリンターを分けて定義
local formatters = {
  biome = require("efmls-configs.formatters.biome"),
  prettier = require("efmls-configs.formatters.prettier"),
  ruff_formatter = require("efmls-configs.formatters.ruff"),
  ruff_sort = require("efmls-configs.formatters.ruff_sort"),
  stylua = require("efmls-configs.formatters.stylua"),
  taplo = require("efmls-configs.formatters.taplo"),
  gofmt = require("efmls-configs.formatters.gofmt"),
}

local linters = {
  eslint = require("efmls-configs.linters.eslint"),
  hadolint = require("efmls-configs.linters.hadolint"),
  markdownlint = require("efmls-configs.linters.markdownlint"),
  ruff_linter = require("efmls-configs.linters.ruff"),
  vint = require("efmls-configs.linters.vint"),
  -- yamllint = require "efmls-configs.linters.yamllint",
  codespell = require("efmls-configs.linters.codespell"),
  luacheck = require("efmls-configs.linters.luacheck"),
}

-- 言語グループの定義
local ecma_languages = {
  "javascript",
  "typescript",
  "javascriptreact",
  "typescriptreact",
  "json",
  "jsonc",
}

local function apply_formatter_to_languages(langs, formatter, languages)
  for _, lang in ipairs(languages) do
    langs[lang] = with(langs[lang], { formatter })
  end
  return langs
end

M.get_languages = function()
  local result = {
    javascript = {},
    typescript = {},
    javascriptreact = {},
    typescriptreact = {},
    json = {},
    jsonc = {},
    gql = {},
    html = {},
    css = {},
    python = {
      linters.ruff_linter,
      formatters.ruff_formatter,
      formatters.ruff_sort,
    },
    lua = { formatters.stylua, linters.luacheck },
    markdown = { linters.markdownlint },
    dockerfile = { linters.hadolint },
    yaml = { linters.yamllint },
    vim = { linters.vint },
    toml = { formatters.taplo },
    go = { formatters.gofmt },
    text = { linters.codespell },
  }

  -- fix stylua
  local stylua_config = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
  local stylua_opts = {
    formatCommand = string.format("stylua --config-path %s/stylua.toml -", stylua_config),
    formatStdin = true,
  }
  formatters.stylua = with(formatters.stylua, stylua_opts.stylua_opts)

  -- ECMA Script Linting
  local has_prettier = utils.has_config_files(formatter_settings.prettier.config_files)
  local has_biome = utils.has_config_files(formatter_settings.biome.config_files)

  if has_biome then
    result.gql = with(result.gql, { formatters.biome })
    result = apply_formatter_to_languages(result, formatters.biome, ecma_languages)
  end

  if has_prettier then
    local target = extend({ "html", "css" }, ecma_languages)
    result = apply_formatter_to_languages(result, formatters.prettier, target)
  end

  return result
end

return M
