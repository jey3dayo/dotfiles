local copilot = safe_require "copilot"
local copilot_cmp = safe_require "copilot_cmp"

if not (copilot and copilot_cmp) then
  return
end

copilot.setup {
  suggestion = { enabled = false },
  panel = { enabled = false },
  copilot_node_command = require("utils").find_command {
    os.getenv "HOME" .. "/.mise/shims/node",
    "/usr/local/bin/node",
  },
}

copilot_cmp.setup {
  formatters = {
    label = require("copilot_cmp.format").format_label_text,
    insert_text = require("copilot_cmp.format").remove_existing,
    preview = require("copilot_cmp.format").deindent,
  },
}
