local hop = safe_require "hop"
local hop_hint = safe_require "hop.hint"

if not (hop and hop_hint) then
  return
end

local directions = hop_hint.HintDirection

hop.setup { keys = "etovxqpdygfblzhckisuran" }

vim.keymap.set("", "s", function()
  hop.hint_char1 { direction = directions.AFTER_CURSOR }
end, { remap = true })
vim.keymap.set("", "S", function()
  hop.hint_char1 { direction = directions.BEFORE_CURSOR }
end, { remap = true })
