local M = {}

local function open_split(command)
  local entry = require("mini.files").get_fs_entry()
  if entry and entry.fs_type == "file" then
    require("mini.files").close()
    vim.cmd(command .. " " .. entry.path)
  end
end

local function setup_buffer_keymaps(buf_id)
  vim.keymap.set("n", "s", function()
    open_split "split"
  end, { buffer = buf_id, desc = "Open in horizontal split" })

  vim.keymap.set("n", "v", function()
    open_split "vsplit"
  end, { buffer = buf_id, desc = "Open in vertical split" })

  local open_file = function()
    require("mini.files").go_in { close_on_file = true }
  end
  vim.keymap.set("n", "<CR>", open_file, { buffer = buf_id, desc = "Open file/directory" })
  vim.keymap.set("n", "o", open_file, { buffer = buf_id, desc = "Open file/directory" })
end

function M.setup()
  require("mini.files").setup {
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 30,
    },
    options = {
      use_as_default_explorer = true,
    },
  }

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      setup_buffer_keymaps(args.data.buf_id)
    end,
  })
end

return M
