local M = {}

-- Module cache to avoid redundant require calls
local _cache = {}
local _failed_cache = {}

-- Safe require with caching
function M.safe_require(module_name)
  -- Return cached result if available
  if _cache[module_name] ~= nil then return _cache[module_name] end

  -- Return nil if previously failed
  if _failed_cache[module_name] then return nil end

  -- Try to require the module
  local ok, result = pcall(require, module_name)

  if ok then
    _cache[module_name] = result
    return result
  else
    _failed_cache[module_name] = true
    return nil
  end
end

-- Batch require multiple modules
function M.require_batch(modules)
  local results = {}
  for alias, module_name in pairs(modules) do
    results[alias] = M.safe_require(module_name)
  end
  return results
end

-- Clear cache (useful for testing/reloading)
function M.clear_cache(module_name)
  if module_name then
    _cache[module_name] = nil
    _failed_cache[module_name] = nil
  else
    _cache = {}
    _failed_cache = {}
  end
end

-- Get cache statistics
function M.get_cache_stats()
  local loaded = vim.tbl_count(_cache)
  local failed = vim.tbl_count(_failed_cache)
  return {
    loaded = loaded,
    failed = failed,
    total = loaded + failed,
    cache_keys = vim.tbl_keys(_cache),
    failed_keys = vim.tbl_keys(_failed_cache),
  }
end

-- Preload commonly used modules
function M.preload_common()
  local common_modules = {
    "core.utils",
    "core.filetypes",
    "lsp.config",
    "lsp.utils",
    "lsp.client_utils",
  }

  for _, module in ipairs(common_modules) do
    M.safe_require(module)
  end
end

return M
