local M = {}

function M.setup()
  local gen = require("mini.extra").gen_ai_spec

  require("mini.ai").setup {
    custom_textobjects = {
      B = gen.buffer(),
      D = gen.diagnostic(),
      I = gen.indent(),
      L = gen.line(),
      N = gen.number(),
      J = { { "()%d%d%d%d%-%d%d%-%d%d()", "()%d%d%d%d%/%d%d%/%d%d()" } },
    },
    n_lines = 500,
  }
end

return M
