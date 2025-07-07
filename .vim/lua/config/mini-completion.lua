-- Mini.completion configuration
local utils = require "core.utils"
local completion = utils.safe_require "mini.completion"

if not completion then return end

-- Setup mini.completion
completion.setup {
  -- Trigger completion manually
  mappings = {
    force_twostep = '<C-l>',  -- Manual completion trigger
    force_fallback = '<A-l>', -- Force fallback completion
  },

  -- LSP + buffer fallback strategy
  sources = {
    -- Primary: LSP completion
    completion.default_lsp_completion,
    -- Fallback: buffer completion when LSP unavailable
    completion.default_fallback_completion,
  },

  -- Window configuration
  window = {
    info = { border = "rounded" },
    signature = { border = "rounded" },
  },

  -- Completion behavior
  delay = { completion = 100, info = 100, signature = 200 },
  fallback_action = '<C-x><C-n>', -- Use built-in completion as fallback
  set_vim_settings = true, -- Set recommended vim settings
}

-- Custom keymaps for completion
local function setup_completion_keymaps()
  -- Insert mode mappings
  local opts = { expr = true, silent = true }
  
  -- Navigation
  vim.keymap.set('i', '<C-n>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-n>'
    end
    return '<C-n>'
  end, opts)
  
  vim.keymap.set('i', '<C-p>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-p>'
    end
    return '<C-p>'
  end, opts)
  
  -- Close completion
  vim.keymap.set('i', '<C-e>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-e>'
    end
    return '<C-e>'
  end, opts)
  
  -- Confirm with <C-k>
  vim.keymap.set('i', '<C-k>', function()
    if vim.fn.pumvisible() == 1 then
      return '<C-y>'
    end
    return '<C-k>'
  end, opts)
  
  -- Enter confirmation (without auto-select)
  vim.keymap.set('i', '<CR>', function()
    if vim.fn.pumvisible() == 1 and vim.fn.complete_changed() then
      return '<C-y>'
    end
    return '<CR>'
  end, opts)
  
  -- Manual completion trigger <C-l>
  vim.keymap.set('i', '<C-l>', function()
    return '<C-x><C-o>'  -- LSP omnifunc completion
  end, opts)
end

-- Setup keymaps
setup_completion_keymaps()

-- LSP integration helper
local function setup_lsp_completion(client, bufnr)
  -- Enable completion capabilities
  if client.server_capabilities.completionProvider then
    vim.bo[bufnr].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
  end
end

-- Auto-setup for LSP buffers
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      setup_lsp_completion(client, args.buf)
    end
  end,
})

-- Filetype-specific completion setup
local function setup_filetype_completion()
  -- Git commit enhanced completion
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gitcommit',
    callback = function()
      vim.bo.omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
    end,
  })
end

setup_filetype_completion()

-- Set recommended vim completion options
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
vim.opt.shortmess:append('c') -- Avoid showing completion messages

-- Integration with mini.pairs for auto-pairing
local function setup_pairs_integration()
  -- mini.pairs automatically integrates with mini.completion
  -- No special configuration needed
  
  -- Optional: Custom handler for function completion to add parentheses
  -- Only activate if you want auto-parentheses for functions
  -- Currently disabled to avoid conflicts with manual control
  
  -- vim.api.nvim_create_autocmd('CompleteDone', {
  --   callback = function()
  --     local completed_item = vim.v.completed_item
  --     if completed_item and completed_item.kind then
  --       -- Add parentheses for functions/methods
  --       if completed_item.kind == 3 or completed_item.kind == 2 then
  --         -- Kind 3 = Function, Kind 2 = Method
  --         local pos = vim.api.nvim_win_get_cursor(0)
  --         local line = vim.api.nvim_get_current_line()
  --         local col = pos[2] + 1
  --         
  --         -- Check if parentheses don't already exist
  --         if col <= #line and line:sub(col, col) ~= '(' then
  --           vim.api.nvim_feedkeys('()', 'n', true)
  --           vim.api.nvim_win_set_cursor(0, {pos[1], pos[2] + 1})
  --         end
  --       end
  --     end
  --   end,
  -- })
end

setup_pairs_integration()

-- Highlight groups
vim.api.nvim_set_hl(0, 'MiniCompletionActiveParameter', { link = 'Visual' })

-- Debug function for troubleshooting
local function debug_completion()
  local info = {
    completion_enabled = vim.bo.omnifunc,
    lsp_clients = vim.tbl_map(function(client) return client.name end, vim.lsp.get_clients()),
    pumvisible = vim.fn.pumvisible() == 1,
  }
  vim.notify(vim.inspect(info), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('MiniCompletionDebug', debug_completion, { desc = 'Debug mini.completion setup' })