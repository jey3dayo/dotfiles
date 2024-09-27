local M = {}

M.user_command = vim.api.nvim_create_user_command

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

M.get_git_dir = function()
  local git_dir = vim.fn.finddir(".git", vim.fn.expand "%:p:h" .. ";")
  if git_dir ~= "" then
    git_dir = vim.fn.fnamemodify(git_dir, ":h")
  end
  return git_dir
end

return M
