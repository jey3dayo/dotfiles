local user_command = require("utils").user_command

local conform = safe_require "conform"
if not conform then
  return
end

vim.g.disable_autoformat = false

-- フォーマッタの存在を確認し、存在しない場合はフォールバックフォーマッタを返す関数
-- ignore_configがtrueの場合、設定ファイルの存在を無視してフォーマッタの有無を確認する
local function get_formatter(bufnr, formatter_name, fallback_formatters, ignore_config)
  local is_exist_config_file = require("lsp.handlers").is_exist_config_files(formatter_name)

  if (ignore_config or is_exist_config_file) and conform.get_formatter_info(formatter_name, bufnr).available then
    -- vim.notify("found: " .. formatter_name, vim.log.levels.INFO)
    return { formatter_name }
  else
    -- vim.notify("fallback: " .. table.concat(fallback_formatters, ","), vim.log.levels.INFO)
    return fallback_formatters
  end
end

-- ECMAScript関連のフォーマッタを取得する関数
local function get_ecma_formatter(bufnr)
  return get_formatter(bufnr, "biome", { "prettier" }, false)
end

local function get_python_formatter(bufnr)
  -- pythonのruffが帰ってこない
  -- return get_formatter(bufnr, "ruff_format", { "isort", "black" }, true)
  return get_formatter(bufnr, "ruff_lsp", { "isort", "black" }, true)
end

conform.setup {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    python = get_python_formatter,
    sql = { "sql_formatter" },
    toml = { "taplo" },
    yaml = { "yamlfmt" },
    json = get_ecma_formatter,
    jsonc = get_ecma_formatter,
    javascriptreact = get_ecma_formatter,
    typescriptreact = get_ecma_formatter,
    javascript = get_ecma_formatter,
    typescript = get_ecma_formatter,
    astro = get_ecma_formatter,
    markdown = { "markdownlint" },
  },
  format_after_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return nil
    end

    return { lsp_fallback = true }
  end,
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

user_command("ConformDisable", function(args)
  if args.bang then
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})

user_command("ConformEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})
