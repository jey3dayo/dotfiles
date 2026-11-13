if vim.g.neovide then
  vim.opt.linespace = 0
  vim.g.neovide_scale_factor = 1.2

  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  -- vim.g.neovide_window_blurred = true

  -- Helper function for transparency formatting
  local alpha = function()
    return string.format("%x", math.floor(255 * (vim.g.transparency or 0.9)))
  end

  vim.g.neovide_transparency = 0.6
  vim.g.transparency = 0.8
  vim.g.neovide_background_color = "#0f1117" .. alpha()
end
