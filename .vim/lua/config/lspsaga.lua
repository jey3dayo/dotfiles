local status, saga = pcall(require, "lspsaga")
if not status then
  return
end

saga.setup {
  code_action_lightbulb = {
    enable = true,
  },
}
