pcall(vim.treesitter.language.register, "yaml", vim.bo.filetype)
vim.cmd.runtime { "ftplugin/yaml.vim", bang = true }
vim.cmd.runtime { "ftplugin/yaml.lua", bang = true }
