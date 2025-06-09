local M = {}
local utils = require "core.utils"

M.setup = function(client)
  local illuminate = utils.safe_require "illuminate"
  if illuminate then illuminate.on_attach(client) end
end

return M
