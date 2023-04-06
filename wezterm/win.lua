local wezterm = require "wezterm"
local wsl_domains = wezterm.default_wsl_domains()

for _, dom in ipairs(wsl_domains) do
  dom.default_cwd = "~"
end

return  {
  default_domain = "WSL:Ubuntu",
  default_prog = { "wsl.exe" },
  launch_menu = { { args = { "cmd.exe" }, domain = { DomainName = "local" } } },

  set_environment_variables = {
    TERMINFO_DIRS = "/home/" .. (os.getenv "USERNAME" or os.getenv "USER") .. "/.nix-profile/share/terminfo",
    WSLENV = "TERMINFO_DIRS",
    prompt = "$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m ",
  },
  wsl_domains = wsl_domains,

  -- window
  window_decorations = "TITLE",
  initial_cols = 130,
  initial_rows = 30,
}