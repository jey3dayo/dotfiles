local user_command = require("utils").user_command

local conform = safe_require "conform"
if not conform then
  return
end

local function get_formatter(bufnr, formatter_name, fallback_formatters)
  if conform.get_formatter_info(formatter_name, bufnr).available then
    return { formatter_name }
  else
    return fallback_formatters
  end
end

local function check_ecma_script(bufnr)
  return get_formatter(bufnr, "biome", { "prettier" })
end

conform.setup {
  format_on_save = function(bufnr)
    -- Disable with a global or buffer-local variable
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return { lsp_fallback = true, timeout_ms = 3000 }
  end,
  format_after_save = {
    lsp_fallback = true,
  },
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "gofmt" },
    _python = function(bufnr)
      if conform.get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
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
    json = check_ecma_script,
    jsonc = check_ecma_script,
    javascriptreact = check_ecma_script,
    typescriptreact = check_ecma_script,
    javascript = check_ecma_script,
    typescript = check_ecma_script,
    astro = check_ecma_script,
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
