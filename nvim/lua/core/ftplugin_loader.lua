local M = {}
local loader = require "core.module_loader"

local ftplugin = loader.safe_require "core.ftplugin"
local filetype_defs = loader.safe_require "core.filetypes"

local config_map = {}

local function unique(list)
  local seen, result = {}, {}
  for _, value in ipairs(list or {}) do
    if value and not seen[value] then
      table.insert(result, value)
      seen[value] = true
    end
  end
  return result
end

local function register(filetype_list, handler)
  if not handler then return end

  if type(filetype_list) == "string" then
    config_map[filetype_list] = handler
    return
  end

  if type(filetype_list) ~= "table" then return end

  for _, filetype in ipairs(filetype_list) do
    config_map[filetype] = handler
  end
end

if ftplugin then
  local function configure_js_like(run_cmd, test_cmd)
    return function(ctx)
      ftplugin.setup_js_like(run_cmd, test_cmd, ctx.buf)
    end
  end

  local function configure_web_lang(opts)
    return function()
      ftplugin.setup_web_lang(opts)
    end
  end

  local js_like_groups = {
    {
      filetypes = { "javascript", "javascriptreact" },
      run_cmd = "babel-node",
      test_cmd = "jest",
    },
    {
      filetypes = { "typescript", "typescriptreact" },
      run_cmd = "ts-node -r tsconfig-paths/register",
      test_cmd = "jest",
    },
  }

  for _, spec in ipairs(js_like_groups) do
    local run_cmd, test_cmd = spec.run_cmd, spec.test_cmd
    register(spec.filetypes, configure_js_like(run_cmd, test_cmd))
  end

  local two_space_languages = { "ruby", "yaml", "json", "haml", "pug" }
  if filetype_defs and type(filetype_defs.web_styles) == "table" then
    two_space_languages = vim.deepcopy(filetype_defs.web_styles)
    vim.list_extend(two_space_languages, { "ruby", "yaml", "json", "haml", "pug" })
  end

  register(unique(two_space_languages), configure_web_lang { tabstop = 2 })
  register("php", configure_web_lang { tabstop = 4 })
end

local function configure_markdown(_ctx)
  local buffer = (_ctx and _ctx.buf) or 0

  if vim.treesitter and vim.treesitter.start then pcall(vim.treesitter.start, buffer, "markdown") end

  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.conceallevel = 2
  vim.opt_local.concealcursor = ""
  vim.opt_local.spell = true
  vim.opt_local.spelllang = "en,cjk"
end

local markdown_filetypes = { "markdown" }
if filetype_defs and type(filetype_defs.markdown) == "table" then markdown_filetypes = filetype_defs.markdown end
register(unique(markdown_filetypes), configure_markdown)

function M.setup()
  if vim.tbl_isempty(config_map) then return end

  local augroup = vim.api.nvim_create_augroup("FtpluginLoader", { clear = true })
  local patterns = vim.tbl_keys(config_map)

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = patterns,
    callback = function(args)
      local handler = config_map[args.match]
      if handler then handler(args) end
    end,
    desc = "Load filetype-specific configurations",
  })
end

function M.get_supported_filetypes()
  return vim.tbl_keys(config_map)
end

function M.is_supported(filetype)
  return config_map[filetype] ~= nil
end

return M
