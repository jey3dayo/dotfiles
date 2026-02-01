local utils = require "core.utils"
local leap = utils.safe_require "leap"
local leap_user = utils.safe_require "leap.user"
if not (leap and leap_user) then return end

-- leap.add_default_mappings()

vim.keymap.set("n", "s", "<Plug>(leap)", { desc = "Leap" })
vim.keymap.set("x", "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
vim.keymap.set("o", "s", "<Plug>(leap-forward)", { desc = "Leap forward" })

vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap from window" })
vim.keymap.set("x", "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
vim.keymap.set("o", "S", "<Plug>(leap-backward)", { desc = "Leap backward" })

vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" }) -- or some grey
vim.api.nvim_set_hl(0, "LeapMatch", { fg = "white", bold = true, nocombine = true })

vim.api.nvim_set_hl(0, "LeapLabelPrimary", { fg = "#f02f87", bold = true, nocombine = true })
vim.api.nvim_set_hl(0, "LeapLabelSecondary", { fg = "#99ddff", bold = true, nocombine = true })

-- Try it without this setting first, you might find you don't even miss it.
-- leap.opts.highlight_unlabeled_phase_one_targets = true
