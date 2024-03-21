local lspsaga = safe_require "lspsaga"
if not lspsaga then
  return
end

lspsaga.setup {
  code_action_lightbulb = {
    enable = true,
  },
}
