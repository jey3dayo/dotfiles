local wezterm = require "wezterm"
local constants = require "./constants"
local wsl_domains = wezterm.default_wsl_domains()

return {
  default_domain = "WSL:Ubuntu",
  default_prog = { "wsl.exe" },
  launch_menu = { { args = { "cmd.exe" }, domain = { DomainName = "local" } } },

  set_environment_variables = {
    TERMINFO_DIRS = "/home/" .. (os.getenv "USERNAME" or os.getenv "USER") .. "/.nix-profile/share/terminfo",
    WSLENV = "TERMINFO_DIRS",
    prompt = "$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m ",
  },
  -- term = "wezterm",
  wsl_domains = wsl_domains,

  -- window
  font_size = constants.windows.font_size,
  initial_cols = constants.windows.initial_cols,
  initial_rows = constants.windows.initial_rows,
  window_decorations = constants.windows.decorations,
}
