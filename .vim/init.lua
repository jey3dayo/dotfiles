if vim.loader then
  vim.loader.enable()
end

require "global_utils"
require "lua_rocks"
require "base"
require "autocmds"
require "options"
require "keymaps"
require "init_lazy"
require "colorscheme"
require "neovide"
require "load_config"
