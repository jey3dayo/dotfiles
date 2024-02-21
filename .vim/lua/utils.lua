local M = {}

M.find_command = function(paths)
  for _, path in ipairs(paths) do
    local file = io.open(path, "r")
    if file then
      file:close()
      return path
    end
  end
  return nil
end

M.extend = function(tab1, tab2)
  for _, value in ipairs(tab2 or {}) do
    table.insert(tab1, value)
  end
  return tab1
end

M.user_command = vim.api.nvim_create_user_command

return M
