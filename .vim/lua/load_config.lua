-- 設定ファイルが存在する場合、そのファイルをVimスクリプトとしてロードする
local config_file = vim.fn.findfile("nvim.config.lua", ";")
if config_file ~= "" then dofile(config_file) end

-- config ディレクトリ内の設定ファイルを自動読み込み
local config_dir = vim.fn.stdpath("config") .. "/lua/config"
if vim.fn.isdirectory(config_dir) == 1 then
  local files = vim.fn.globpath(config_dir, "*.lua", false, true)
  for _, file in ipairs(files) do
    local module_name = "config." .. vim.fn.fnamemodify(file, ":t:r")
    pcall(require, module_name)
  end
end
