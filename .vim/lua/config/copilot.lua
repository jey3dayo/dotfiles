local status1, copilot = pcall(require, "copilot")
if not status1 then
  return
end

local status2, copilot_cmp = pcall(require, "copilot_cmp")
if not status2 then
  return
end

copilot.setup {
  suggestion = { enabled = false },
  panel = { enabled = false },
}

copilot_cmp.setup()
