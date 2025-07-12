-- nvim-lint configuration for lightweight linting
local lint = require "lint"
local utils = require "core.utils"
local lsp_config = require "lsp.config"

-- Configure linters by filetype using centralized config
lint.linters_by_ft = lsp_config.linters

-- Enhanced linter configurations
lint.linters.eslint = require("lint.util").wrap(lint.linters.eslint, function(diagnostic)
  -- Only run eslint if config file exists (using centralized config)
  local config_files = lsp_config.formatters.eslint.config_files
  
  if not utils.has_config_files(config_files) then
    return {}
  end
  
  return diagnostic
end)

-- Configure luacheck to work with Neovim Lua API
lint.linters.luacheck.args = {
  "--formatter",
  "plain",
  "--codes",
  "--ranges",
  "--globals",
  "vim",
  "-",
}

-- Configure ruff for Python
lint.linters.ruff.args = {
  "check",
  "--output-format=json", 
  "--stdin-filename",
  function() return vim.api.nvim_buf_get_name(0) end,
  "-",
}

-- Auto-lint setup
local lint_augroup = vim.api.nvim_create_augroup("nvim-lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    -- Don't lint if disabled
    if vim.g.disable_autolint or vim.b.disable_autolint then
      return
    end
    
    -- Debounce linting to avoid excessive runs
    local timer = vim.loop.new_timer()
    timer:start(100, 0, vim.schedule_wrap(function()
      lint.try_lint()
      timer:close()
    end))
  end,
})

-- Commands for controlling auto-lint
vim.api.nvim_create_user_command("AutoLintDisable", function(args)
  if args.bang then
    -- AutoLintDisable! will disable linting globally
    vim.g.disable_autolint = true
  else
    -- AutoLintDisable will disable linting for current buffer
    vim.b.disable_autolint = true
  end
  vim.notify("Auto-linting disabled", vim.log.levels.INFO)
end, {
  desc = "Disable automatic linting",
  bang = true,
})

vim.api.nvim_create_user_command("AutoLintEnable", function()
  vim.b.disable_autolint = false
  vim.g.disable_autolint = false
  vim.notify("Auto-linting enabled", vim.log.levels.INFO)
end, {
  desc = "Re-enable automatic linting",
})

-- Manual lint command
vim.api.nvim_create_user_command("Lint", function()
  lint.try_lint()
end, { desc = "Run linters for current buffer" })

-- Debug info command
vim.api.nvim_create_user_command("LintInfo", function()
  local ft = vim.bo.filetype
  local linters = lint.linters_by_ft[ft] or lint.linters_by_ft["*"] or {}
  
  if #linters == 0 then
    vim.notify("No linters configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end
  
  local available = {}
  local unavailable = {}
  
  for _, linter_name in ipairs(linters) do
    local linter = lint.linters[linter_name]
    if linter then
      -- Check if the linter command exists
      local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
      if vim.fn.executable(cmd) == 1 then
        table.insert(available, linter_name)
      else
        table.insert(unavailable, linter_name .. " (" .. cmd .. " not found)")
      end
    end
  end
  
  local msg = "Filetype: " .. ft .. "\n"
  if #available > 0 then
    msg = msg .. "Available linters: " .. table.concat(available, ", ") .. "\n"
  end
  if #unavailable > 0 then
    msg = msg .. "Unavailable linters: " .. table.concat(unavailable, ", ")
  end
  
  vim.notify(msg, vim.log.levels.INFO)
end, { desc = "Show linter info for current buffer" })