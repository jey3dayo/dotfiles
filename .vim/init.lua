if vim.loader then
  vim.loader.enable()
end

require "base"
require "autocmds"
require "options"
require "keymaps"
require "init_lazy"
require "colorscheme"
