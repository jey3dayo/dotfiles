local util = require("lspconfig.util")
local unpack = table.unpack or unpack

local M = {}

M.create_root_pattern = function(patterns)
  return function(fname)
    return util.root_pattern(unpack(patterns))(fname)
  end
end

return M
