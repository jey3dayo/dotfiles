-- Compatibility shims for deprecated Neovim APIs

local function patch_str_utfindex()
  if not vim.str_utfindex or not vim._str_utfindex then return end

  local native = vim.str_utfindex

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.str_utfindex = function(s, encoding, index, strict_indexing)
    if encoding == nil or type(encoding) == "number" then
      local idx = encoding
      local col32, col16 = vim._str_utfindex(s, idx)
      if not col32 or not col16 then error "index out of range" end
      return col32, col16
    end
    return native(s, encoding, index, strict_indexing)
  end
end

patch_str_utfindex()
