local M = {}

function M.setup()
  require("mini.jump2d").setup {
    spotter = require("mini.jump2d").builtin_opts.single_character.spotter,
    mappings = {
      start_jumping = "<CR>",
    },
  }
end

return M
