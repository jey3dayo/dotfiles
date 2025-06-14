if vim.loader then vim.loader.enable() end

-- Core modules that need to load early
require "core.utils"
require "base"
require "options"
require "keymaps"
require "filetype"
require "init_lazy"

-- Defer heavy modules until after UI is ready
vim.defer_fn(function()
  require "lua_rocks"
  require "autocmds"
  require "colorscheme"
  require "load_config"
  require "lsp.autoformat"

  -- Load neovide config only if running in neovide
  if vim.g.neovide then require "neovide" end
end, 0)
