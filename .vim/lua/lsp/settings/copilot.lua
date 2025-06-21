-- Copilot is handled by copilot.lua plugin, not as a regular LSP
-- This file prevents the "copilot does not have a configuration" warning
return {
  -- Disable auto-start as Copilot is managed by the plugin
  autostart = false,
  -- Empty setup to satisfy LSP config requirements
  cmd = {},
  filetypes = {},
}

