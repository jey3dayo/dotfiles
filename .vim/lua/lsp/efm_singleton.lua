local M = {}

-- Track if EFM has been set up
local efm_setup_done = false

-- Check if EFM client already exists
local function efm_client_exists()
  local clients = vim.lsp.get_active_clients({ name = "efm" })
  return #clients > 0
end

-- Setup function to be called from mason-lspconfig
function M.setup(opts)
  if efm_setup_done or efm_client_exists() then
    return  -- Already set up, prevent duplicate setup
  end
  
  local lspconfig = require("lspconfig")
  
  -- Ensure single_file_support is true to prevent multiple instances
  opts.single_file_support = true
  
  -- Add custom on_init to track setup
  local original_on_init = opts.on_init
  opts.on_init = function(client, initialize_result)
    -- Mark that we have an EFM instance
    efm_setup_done = true
    
    if original_on_init then
      return original_on_init(client, initialize_result)
    end
  end
  
  -- Add autostart control
  opts.autostart = true
  
  lspconfig.efm.setup(opts)
  efm_setup_done = true
end

return M
