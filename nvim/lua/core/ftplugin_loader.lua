local M = {}
local loader = require "core.module_loader"

-- Cache ftplugin base module
local ftplugin = loader.safe_require "core.ftplugin"

-- Filetype configuration definitions
local config_map = {
  -- JavaScript/TypeScript family
  javascript = function()
    if ftplugin then ftplugin.setup_js_like("babel-node", "jest") end
  end,

  javascriptreact = function()
    if ftplugin then ftplugin.setup_js_like("babel-node", "jest") end
  end,

  typescript = function()
    if ftplugin then ftplugin.setup_js_like("ts-node -r tsconfig-paths/register", "jest") end
  end,

  typescriptreact = function()
    if ftplugin then ftplugin.setup_js_like("ts-node -r tsconfig-paths/register", "jest") end
  end,

  -- Web languages with 2-space indentation
  ruby = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  css = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  less = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  sass = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  yaml = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  json = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  haml = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  pug = function()
    if ftplugin then ftplugin.setup_web_lang { tabstop = 2 } end
  end,

  php = function()
    if ftplugin then
      ftplugin.setup_web_lang { tabstop = 4 } -- PHP typically uses 4 spaces
    end
  end,

  -- Special cases
  markdown = function()
    -- Ensure treesitter highlighting is started for markdown buffers
    if vim.treesitter.get_parser then vim.treesitter.start(0, "markdown") end

    -- Markdown specific settings
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""

    -- Enable spell checking for markdown
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en,cjk"
  end,
}

-- Setup function to register all filetype configs
function M.setup()
  local augroup = vim.api.nvim_create_augroup("FtpluginLoader", { clear = true })

  -- Create single autocmd for all filetypes
  local filetypes = vim.tbl_keys(config_map)

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = filetypes,
    callback = function(args)
      local config = config_map[args.match]
      if config then config() end
    end,
    desc = "Load filetype-specific configurations",
  })
end

-- Get supported filetypes (for debugging)
function M.get_supported_filetypes()
  return vim.tbl_keys(config_map)
end

-- Check if a filetype is supported
function M.is_supported(filetype)
  return config_map[filetype] ~= nil
end

return M
