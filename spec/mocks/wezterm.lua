-- Mock wezterm module for testing
local M = {}

-- Mock wezterm.font_with_fallback
function M.font_with_fallback(names, params)
  return {
    names = names,
    params = params or {},
    family = names[1],
  }
end

-- Mock wezterm.target_triple for platform detection
M.target_triple = "x86_64-apple-darwin" -- Default to macOS

-- Mock wezterm.time for event tests (future expansion)
M.time = {
  call_after = function(seconds, callback)
    return { seconds = seconds, callback = callback }
  end,
}

-- Mock wezterm.on for event registration (future expansion)
M.on = function(event_name, handler)
  M._event_handlers = M._event_handlers or {}
  M._event_handlers[event_name] = handler
end

return M
