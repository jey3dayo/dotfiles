-- 設定ファイルが存在する場合、そのファイルをVimスクリプトとしてロードする
local config_file = vim.fn.findfile("nvim.config.lua", ";")
if config_file ~= "" then
  dofile(config_file)
end
