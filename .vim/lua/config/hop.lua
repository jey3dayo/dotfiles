local utils = require "core.utils"
local hop = utils.safe_require "hop"
local hop_hint = utils.safe_require "hop.hint"

if not (hop and hop_hint) then return end

hop.setup { keys = "etovxqpdygfblzhckisuran" }

local directions = hop_hint.HintDirection
vim.keymap.set("", "s", function()
  hop.hint_char1 { direction = directions.AFTER_CURSOR }
end, { remap = true })
vim.keymap.set("", "S", function()
  hop.hint_char1 { direction = directions.BEFORE_CURSOR }
end, { remap = true })
