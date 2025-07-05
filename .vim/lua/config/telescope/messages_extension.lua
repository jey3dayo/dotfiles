-- Telescope extension for :messages
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function messages_history(opts)
  opts = opts or {}
  
  -- Get messages history
  local messages = vim.api.nvim_exec2("messages", { output = true }).output
  if not messages or messages == "" then
    local notify_helper = require("core.notify")
    notify_helper.info(notify_helper.warnings.no_items("messages in history"))
    return
  end
  
  -- Split messages into lines
  local lines = vim.split(messages, '\n')
  local results = {}
  
  -- Process each line
  for i, line in ipairs(lines) do
    if line ~= "" then
      table.insert(results, {
        id = i,
        ordinal = line,
        display = line,
        value = line,
      })
    end
  end
  
  -- Reverse to show newest first
  local reversed = {}
  for i = #results, 1, -1 do
    table.insert(reversed, results[i])
  end
  results = reversed
  
  pickers.new(opts, {
    prompt_title = 'Message History',
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return entry
      end,
    },
    sorter = conf.generic_sorter(opts),
    previewer = false, -- Messages don't need preview
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          -- Copy to clipboard
          vim.fn.setreg('+', selection.value)
          vim.fn.setreg('"', selection.value)
          vim.notify('Message copied to clipboard', vim.log.levels.INFO)
        end
      end)
      
      -- Add keybinding to copy all messages
      map('i', '<C-a>', function()
        actions.close(prompt_bufnr)
        vim.fn.setreg('+', messages)
        vim.fn.setreg('"', messages)
        vim.notify('All messages copied to clipboard', vim.log.levels.INFO)
      end)
      
      -- Add keybinding to clear messages
      map('i', '<C-c>', function()
        actions.close(prompt_bufnr)
        vim.cmd('messages clear')
        vim.notify('Messages cleared', vim.log.levels.INFO)
      end)
      
      -- Add keybinding to show in buffer
      map('i', '<C-v>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          -- Create a new buffer with the message
          vim.cmd('new')
          vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(selection.value, '\n'))
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
          vim.bo.swapfile = false
        end
      end)
      
      return true
    end,
  }):find()
end

-- Return the extension definition
return {
  exports = {
    messages = messages_history,
  },
}