local config_file = vim.fn.findfile("nvim.config.lua", ";")
if config_file ~= "" then dofile(config_file) end
