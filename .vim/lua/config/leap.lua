local leap = Safe_require("leap")
local leap_user = Safe_require("leap.user")
if not (leap and leap_user) then
  return
end

-- leap.add_default_mappings()

Keymap("s", "<Plug>(leap)")
X_Keymap("s", "<Plug>(leap-forward)")
O_Keymap("s", "<Plug>(leap-forward)")

Keymap("S", "<Plug>(leap-from-window)")
X_Keymap("S", "<Plug>(leap-backward)")
O_Keymap("S", "<Plug>(leap-backward)")

vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" }) -- or some grey
vim.api.nvim_set_hl(0, "LeapMatch", { fg = "white", bold = true, nocombine = true })

vim.api.nvim_set_hl(0, "LeapLabelPrimary", { fg = "#f02f87", bold = true, nocombine = true })
vim.api.nvim_set_hl(0, "LeapLabelSecondary", { fg = "#99ddff", bold = true, nocombine = true })

-- Try it without this setting first, you might find you don't even miss it.
-- leap.opts.highlight_unlabeled_phase_one_targets = true
