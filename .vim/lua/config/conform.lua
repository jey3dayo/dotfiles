local user_command = require("utils").user_command

local conform = safe_require "conform"
if not conform then
  return
end

-- 指定されたフォーマッタが存在するか確認し、存在しない場合はフォールバックフォーマッタを返す関数
local function get_formatter(bufnr, formatter_name, fallback_formatters)
  local is_exist_config_file = require("lsp.handlers").is_exist_config_files(formatter_name)
  if is_exist_config_file and conform.get_formatter_info(formatter_name, bufnr).available then
    return { formatter_name }
  else
    return fallback_formatters
  end
end

-- ECMAScript関連のフォーマッタを取得する関数
local function get_ecma_formatter(bufnr)
  return get_formatter(bufnr, "biome", { "prettier" })
end

conform.setup {
  format_after_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end

    return { lsp_fallback = true }
  end,
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    python = function(bufnr)
      if conform.get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
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
