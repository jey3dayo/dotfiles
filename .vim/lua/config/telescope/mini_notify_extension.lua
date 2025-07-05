-- Telescope extension for mini.notify
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function notify_history(opts)
  opts = opts or {}
  
  -- Check if mini.notify is available
  local has_mini_notify, mini_notify = pcall(require, "mini.notify")
  if not has_mini_notify then
    local notify_helper = require("core.notify")
    notify_helper.error(notify_helper.errors.module_not_available("mini.notify"))
    return
  end
  
  local results = {}
  
  -- Get all notifications
  local all_notifications = mini_notify.get_all()
  if all_notifications then
    for id, n in pairs(all_notifications) do
      local level_map = {
        ERROR = 'ERROR',
        WARN = 'WARN',
        INFO = 'INFO',
        DEBUG = 'DEBUG',
        TRACE = 'TRACE',
      }
      local level = level_map[n.level] or tostring(n.level or 'INFO')
      local msg = (n.msg or ''):gsub('\n', ' ')
      
      table.insert(results, {
        id = id,
        ordinal = msg,
        display = string.format('[%-5s] %s', level, msg),
        value = n,
      })
    end
  end
  
  -- Sort by id (newest first)
  table.sort(results, function(a, b) return a.id > b.id end)
  
  pickers.new(opts, {
    prompt_title = 'Notification History',
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return entry
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = false, -- Disable previewer to avoid path error
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Copy to clipboard
          vim.fn.setreg('+', selection.value.msg)
          vim.fn.setreg('"', selection.value.msg)
          local notify_helper = require("core.notify")
          notify_helper.info(notify_helper.info.copied_to_clipboard("Notification"))
        end
      end)
      
      -- Add keybinding to show full notification in buffer
      map('i', '<C-v>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          -- Create a new buffer with the full notification
          vim.cmd('new')
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(selection.value.msg, '\n'))
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
          vim.bo.filetype = 'markdown'
        end
      end)
      
      -- Add keybinding to clear all notifications
      map('i', '<C-c>', function()
        actions.close(prompt_bufnr)
        mini_notify.clear()
        vim.notify('All notifications cleared', vim.log.levels.INFO)
      end)
      
      return true
    end,
  }):find()
end

-- Return the extension definition
return {
  exports = {
    mini_notify = notify_history,
  },
}