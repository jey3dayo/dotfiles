-- Minimal config loader for standalone configurations
-- Most plugin configs are loaded explicitly in plugin definitions for better lazy loading
local loader = require "core.module_loader"

-- Load project-specific config if it exists (for local development)
local config_file = vim.fn.findfile("nvim.config.lua", ";")
if config_file ~= "" then dofile(config_file) end

-- Only load standalone config files that aren't handled by plugin definitions
-- These are configurations that don't depend on plugins being loaded
local standalone_configs = {}

for _, config_name in ipairs(standalone_configs) do
  loader.safe_require("config." .. config_name)
end
