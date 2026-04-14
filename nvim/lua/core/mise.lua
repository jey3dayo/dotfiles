local M = {}

local uv = vim.uv or vim.loop

function M.latest_installed_binary(install_name, binary_relpath)
  if not uv or not uv.fs_scandir then return nil end

  local root = vim.fn.expand("~/.mise/installs/" .. install_name)
  local handle = uv.fs_scandir(root)
  if not handle then return nil end

  local candidates = {}
  while true do
    local name, kind = uv.fs_scandir_next(handle)
    if not name then break end
    if kind == "directory" then
      local candidate = root .. "/" .. name .. "/" .. binary_relpath
      if vim.fn.executable(candidate) == 1 then table.insert(candidates, candidate) end
    end
  end

  if vim.tbl_isempty(candidates) then return nil end

  table.sort(candidates, function(a, b)
    local a_version = vim.fs.basename(vim.fs.dirname(a))
    local b_version = vim.fs.basename(vim.fs.dirname(b))
    local a_ok, a_parsed = pcall(vim.version.parse, a_version)
    local b_ok, b_parsed = pcall(vim.version.parse, b_version)

    if a_ok and b_ok then return vim.version.lt(b_parsed, a_parsed) end
    return a > b
  end)

  local binary = candidates[1]
  if vim.fn.executable(binary) == 1 then return binary end
  return nil
end

function M.resolve_command(cmd, opts)
  opts = opts or {}

  if opts.install_name and opts.binary_relpath then
    local latest = M.latest_installed_binary(opts.install_name, opts.binary_relpath)
    if latest then return latest end
  end

  local shim = vim.fn.expand("~/.mise/shims/" .. cmd)
  if vim.fn.executable(shim) == 1 then return shim end

  return cmd
end

return M
