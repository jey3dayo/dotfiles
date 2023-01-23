vim.cmd("autocmd!")
vim.scriptencoding = "utf-8"
vim.wo.number = true

configDir = os.getenv("XDG_CONFIG_HOME") .. "/.vim"
cacheDir = os.getenv("XDG_CACHE_HOME") .. "/.vim"
