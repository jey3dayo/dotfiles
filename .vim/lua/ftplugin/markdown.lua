-- Ensure treesitter highlighting is started for markdown buffers
if vim.treesitter.get_parser then vim.treesitter.start(0, "markdown") end

-- Markdown specific settings
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.conceallevel = 2
vim.opt_local.concealcursor = ""

-- Enable spell checking for markdown
vim.opt_local.spell = true
vim.opt_local.spelllang = "en,cjk"
