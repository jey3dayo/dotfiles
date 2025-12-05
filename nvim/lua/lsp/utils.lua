local util = require "lspconfig.util"
local unpack = table.unpack or unpack

local M = {}

M.create_root_pattern = function(patterns)
  return function(fname)
    return util.root_pattern(unpack(patterns))(fname)
  end
end

-- Resolve a path inside a Mason package if it is installed
-- Returns nil when the package or path is unavailable
M.get_mason_package_path = function(pkg_name, relative_path)
  local ok_registry, registry = pcall(require, "mason-registry")
  if not ok_registry then return nil end

  local ok_pkg, pkg = pcall(registry.get_package, pkg_name)
  if not ok_pkg or not pkg then return nil end
  if type(pkg.is_installed) ~= "function" or type(pkg.get_install_path) ~= "function" then return nil end
  if not pkg:is_installed() then return nil end

  local base = pkg:get_install_path()
  if not relative_path then return base end

  local path = vim.fs.joinpath(base, relative_path)
  local stat = vim.loop.fs_stat(path)
  return stat and path or nil
end

return M
