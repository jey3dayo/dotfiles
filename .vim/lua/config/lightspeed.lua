local status, lightspeed = pcall(require, "lightspeed")
if not status then
  return
end

lightspeed.setup {}
