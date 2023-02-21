local wezterm = require "wezterm"
local utils = require "utils"

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local title = wezterm.truncate_right(utils.basename(tab.active_pane.foreground_process_name), max_width)
  if title == "" then
    title =
        wezterm.truncate_right(utils.basename(utils.convert_home_dir(tab.active_pane.current_working_dir)), max_width)
  end
  return {
    { Text = tab.tab_index + 1 .. ":" .. title },
  }
end)
