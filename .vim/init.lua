if vim.loader then vim.loader.enable() end

-- Load LSP safety modules early
require "lsp.quiet"  -- Early LSP quiet mode setup

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
  -- Client tracking simplified and moved to client_utils.lua
  require "autocmds"
  require "colorscheme"
  require "load_config"
  require "lsp.autoformat"

  -- Load neovide config only if running in neovide
  if vim.g.neovide then require "neovide" end
end, 0)
