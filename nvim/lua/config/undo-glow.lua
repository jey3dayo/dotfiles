local M = {}

function M.opts()
  return {
    animation = {
      enabled = true,
      duration = 100,
      animation_type = "fade",
      fps = 120,
      easing = "in_out_cubic",
    },
    priority = 4096,
    color_cache_size = 1000,
    debounce_delay = 50,
    fallback_for_transparency = {
      bg = "#16161d",
      fg = "#dcd7ba",
    },
  }
end

local function jump_to_paste_end()
  vim.cmd.normal { args = { "`]" }, bang = true }
end

function M.setup(opts)
  local undo_glow = require "undo-glow"
  undo_glow.setup(opts)

  vim.keymap.set("n", "u", undo_glow.undo, { desc = "Undo with highlight" })
  vim.keymap.set("n", "U", undo_glow.redo, { desc = "Redo with highlight" })

  vim.keymap.set("n", "p", function()
    undo_glow.paste_below()
    jump_to_paste_end()
  end, { desc = "Paste below with highlight" })

  vim.keymap.set("n", "P", function()
    undo_glow.paste_above()
    jump_to_paste_end()
  end, { desc = "Paste above with highlight" })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("UndoGlowYank", { clear = true }),
    desc = "Highlight yanked text with undo-glow animation",
    callback = undo_glow.yank,
  })

  vim.keymap.set({ "n", "x", "o" }, "s", function()
    require("undo-glow").flash_jump()
  end, { desc = "Flash jump with highlight" })
end

return M
