vim.g.mapleader = ","

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<C-d>", "<cmd>bd<CR>")
map("n", "<Tab>", "<cmd>wincmd w<CR>")
map("n", "gF", "0f v$gf")
map("v", "gF", "0f v$gf")

-- ESC ESC -> toggle hlsearch
map("n", "<Esc><Esc>", function()
  vim.cmd "set hlsearch!"
end)

-- LSP tag jump (modern replacement for ctags)
map("n", "tt", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "tj", vim.lsp.buf.references, { desc = "Find references" })
map("n", "tk", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "tl", vim.lsp.buf.type_definition, { desc = "Go to type definition" })

-- tab (direct mappings for mini.clue compatibility)
map("n", "<C-t>c", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<C-t>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<C-t>o", "<cmd>tab split<CR>", { desc = "Split tab" })
map("n", "<C-t>n", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<C-t>p", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

map("n", "gt", "<cmd>tabnext<CR>")
map("n", "gT", "<cmd>tabprevious<CR>")

-- toggles and maintenance
map("n", "<Leader>sn", "<cmd>set number!<CR>", { desc = "Toggle line numbers" })
map("n", "<Leader>sL", "<cmd>set list!<CR>", { desc = "Toggle list mode" })
map("n", "<Leader>sp", "<cmd>Lazy<CR>", { desc = "Plugin manager" })
map("n", "<Leader>sd", "<cmd>LspDebug<CR>", { desc = "LspDebug" })
map("n", "<Leader>sm", "<cmd>MasonUpdate<CR>", { desc = "Update Mason" })
map("n", "<Leader>st", "<cmd>TSUpdate all<CR>", { desc = "Update TreeSitter" })
map("n", "<Leader>su", "<cmd>Lazy update<CR>", { desc = "Update plugins" })

-- Load a config file
local function load_config(config_path)
  vim.cmd("source " .. config_path)
  vim.api.nvim_echo({ { "Loaded config: " .. config_path, "None" } }, true, {})
end

-- Source the main config
local function source_config()
  local config_path = vim.fn.stdpath "config" .. "/init.lua"
  load_config(config_path)
end
map("n", "<Leader>so", source_config, { desc = "Source init.lua" })

-- Source the current config
local function source_current_config()
  local config_path = vim.fn.expand "%:p"
  load_config(config_path)
end
map("n", "<Leader>sO", source_current_config, { desc = "Source current buffer" })

local function copy_to_clipboard(text, message)
  if not text or text == "" then return end
  vim.fn.setreg("*", text)
  vim.api.nvim_echo({ { message or ("Copied: " .. text), "None" } }, true, {})
end

local function register_copy_map(lhs, builder, desc)
  map("n", lhs, function()
    local text, message = builder()
    copy_to_clipboard(text, message)
  end, { desc = desc })
end

register_copy_map("Yf", function()
  local path = vim.fn.expand "%:."
  return path, "Copied: " .. path
end, "Copy relative file path")

register_copy_map("Yl", function()
  local path = vim.fn.expand "%:."
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local text = string.format("%s:%d", path, line)
  return text, "Copied: " .. text
end, "Copy file path with line")

register_copy_map("YF", function()
  local path = vim.fn.expand "%:p"
  return path, "Copied: " .. path
end, "Copy absolute file path")

register_copy_map("Yd", function()
  local dir = vim.fn.expand "%:p:h"
  return dir, "Copied: " .. dir
end, "Copy directory path")

register_copy_map("YD", function()
  local dir = vim.fn.expand "%:.:h"
  return dir, "Copied: " .. dir
end, "Copy relative directory")

register_copy_map("YY", function()
  local path = vim.fn.expand "%:."
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  local text = string.format("%s\n```\n%s\n```\n", path, content)
  return text, "Copied buffer: " .. path
end, "Copy buffer with path and content")

-- Format keybindings (LSP-based)
map("n", "<C-e>f", "<cmd>Format<CR>", { desc = "Format (auto-select)" })

-- Individual formatter keymaps
map("n", "<C-e>b", "<cmd>FormatWithBiome<CR>", { desc = "Format with Biome" })
map("n", "<C-e>p", "<cmd>FormatWithPrettier<CR>", { desc = "Format with Prettier" })
map("n", "<C-e>e", "<cmd>FormatWithEslint<CR>", { desc = "Format with ESLint" })
map("n", "<C-e>s", "<cmd>FormatWithTsLs<CR>", { desc = "Format with TypeScript" })
