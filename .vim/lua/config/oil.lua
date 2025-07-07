local utils = require "core.utils"
local oil = utils.safe_require "oil"
if not oil then return end

oil.setup {
  default_file_explorer = true,
  columns = {
    "icon",
  },
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["<C-s>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-l>"] = "actions.refresh",
    ["-"] = "actions.parent",
    ["gu"] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["~"] = "actions.tcd",
    ["gs"] = "actions.change_sort",
    ["gx"] = "actions.open_external",
    ["g."] = "actions.toggle_hidden",
  },
  use_default_keymaps = true,
  view_options = {
    show_hidden = false,
    is_always_hidden = function(name, bufnr)
      return name == ".." and false or false
    end,
  },
}

-- Keymaps
Keymap("<Leader>e", function()
  local git_dir = utils.get_git_dir()
  if git_dir ~= "" then
    oil.open(git_dir)
  else
    oil.open(vim.fn.getcwd())
  end
end, { desc = "Open git dir with Oil" })

Keymap("<Leader>E", function()
  oil.open(vim.fn.expand "%:p:h")
end, { desc = "Open buffer dir with Oil" })

