-- 設定ファイルが存在する場合、そのファイルをVimスクリプトとしてロードする
local config_file = vim.fn.findfile("nvim.config.lua", ";")
if config_file ~= "" then dofile(config_file) end

-- config ディレクトリ内の設定ファイルを自動読み込み
-- NOTE: Most configs are now loaded explicitly in plugin definitions
-- This auto-loading is kept for backward compatibility and standalone configs
local config_dir = vim.fn.stdpath "config" .. "/lua/config"
if vim.fn.isdirectory(config_dir) == 1 then
  local files = vim.fn.globpath(config_dir, "*.lua", false, true)
  -- Skip files that are already loaded by plugins
  local skip_files = {
    "nvim-treesitter.lua",
    "rainbow-delimiters.lua",
    "vim-repeat.lua",
    "gitsigns.lua",
    "diffview.lua",
    "lualine.lua",
    "conform.lua",
    "nvim-lint.lua",
    "mason.lua",
    "mason-lspconfig.lua",
    "mini-completion.lua",
  }

  for _, file in ipairs(files) do
    local filename = vim.fn.fnamemodify(file, ":t")
    local should_skip = false

    for _, skip_file in ipairs(skip_files) do
      if filename == skip_file then
        should_skip = true
        break
      end
    end

    if not should_skip then
      local module_name = "config." .. vim.fn.fnamemodify(file, ":t:r")
      pcall(require, module_name)
    end
  end
end
