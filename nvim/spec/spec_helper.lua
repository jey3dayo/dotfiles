-- spec_helper.lua
-- Busted test helper for Neovim Lua modules

-- Mock vim global for testing outside Neovim
_G.vim = {
  log = {
    levels = {
      DEBUG = 0,
      ERROR = 1,
      INFO = 2,
      TRACE = 3,
      WARN = 4,
    },
  },
  notify = function(msg, level)
    print(string.format("[%s] %s", level or "INFO", msg))
  end,
  deepcopy = function(orig)
    local copy
    if type(orig) == "table" then
      copy = {}
      for k, v in next, orig, nil do
        copy[vim.deepcopy(k)] = vim.deepcopy(v)
      end
      setmetatable(copy, vim.deepcopy(getmetatable(orig)))
    else
      copy = orig
    end
    return copy
  end,
  tbl_deep_extend = function(behavior, ...)
    local result = {}
    local function merge(t1, t2)
      for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
          if behavior == "force" then
            t1[k] = merge(t1[k], v)
          end
        else
          t1[k] = v
        end
      end
      return t1
    end

    for _, tbl in ipairs { ... } do
      result = merge(result, tbl)
    end
    return result
  end,
  list_extend = function(dst, src)
    for _, v in ipairs(src) do
      table.insert(dst, v)
    end
    return dst
  end,
  fn = {
    getcwd = function()
      return "/tmp/test"
    end,
    fnamemodify = function(path, modifier)
      if modifier == ":t" then return path:match "([^/]+)$" or path end
      return path
    end,
  },
  uri_from_fname = function(path)
    return "file://" .. path
  end,
}

-- Add lua/ directory to package path for requiring modules
local nvim_path = vim.fn.getcwd() .. "/lua"
package.path = package.path .. ";" .. nvim_path .. "/?.lua;" .. nvim_path .. "/?/init.lua"

return {}
