local util = require "lspconfig.util"

local M = {}

M.create_root_pattern = function(patterns)
  return function(fname)
    return util.root_pattern(unpack(patterns))(fname)
  end
end

return M
