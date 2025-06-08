local M = {}

M.setup = function(client)
  local illuminate = Safe_require("illuminate")
  if illuminate then
    illuminate.on_attach(client)
  end
end

return M
