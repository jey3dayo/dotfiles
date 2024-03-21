local autopairs = safe_require "nvim-autopairs"

if not autopairs then
  return
end

autopairs.setup {
  disable_filetype = { "TelescopePrompt", "vim" },
}
