vim.g.mapleader = ","

local noremap_opts = { noremap = true, silent = true }
local silent_opts = { silent = true }

local function set_keymap(mode, key, value, opts)
  opts = opts or (mode == "n" and noremap_opts or silent_opts)
  vim.keymap.set(mode, key, value, opts)
end

-- Legacy Keymap functions removed - use vim.keymap.set directly

-- deprecated
function Set_keymap(key, value, _opts)
  if not _opts then _opts = silent_opts end
  vim.api.nvim_set_keymap("n", key, value, _opts)
  vim.api.nvim_set_keymap("v", key, value, _opts)
end

function Buf_set_keymap(key, value, buf)
  vim.api.nvim_buf_set_keymap(buf, "n", key, value, noremap_opts)
end

vim.keymap.set("n", "<C-d>", "<cmd>bd<CR>")
vim.keymap.set("n", "<Tab>", "<cmd>wincmd w<CR>")
vim.keymap.set("n", "gF", "0f v$gf")
vim.keymap.set("v", "gF", "0f v$gf")

-- ESC ESC -> toggle hlsearch
vim.keymap.set("n", "<Esc><Esc>", function()
  vim.cmd "set hlsearch!"
end)

-- LSP tag jump (modern replacement for ctags)
vim.keymap.set("n", "tt", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
vim.keymap.set("n", "tj", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "Find references" })
vim.keymap.set("n", "tk", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
vim.keymap.set("n", "tl", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Go to type definition" })

-- tab (direct mappings for mini.clue compatibility)
vim.keymap.set("n", "<C-t>c", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<C-t>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<C-t>o", "<cmd>tab split<CR>", { desc = "Split tab" })
vim.keymap.set("n", "<C-t>n", "<cmd>tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<C-t>p", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

vim.keymap.set("n", "gt", "<cmd>tabnext<CR>")
vim.keymap.set("n", "gT", "<cmd>tabprevious<CR>")

-- set list
vim.keymap.set("n", "<Leader>sn", "<cmd>set number!<CR>", { desc = "Toggle line numbers" })
vim.keymap.set("n", "<Leader>sL", "<cmd>set list!<CR>", { desc = "Toggle list mode" })
vim.keymap.set("n", "<Leader>sp", "<cmd>Lazy<CR>", { desc = "Plugin manager" })
vim.keymap.set("n", "<Leader>sd", "<cmd>LspDebug<CR>", { desc = "LspDebug" })
vim.keymap.set("n", "<Leader>sm", "<cmd>MasonUpdate<CR>", { desc = "Update Mason" })
vim.keymap.set("n", "<Leader>st", "<cmd>TSUpdate all<CR>", { desc = "Update TreeSitter" })

-- update source
vim.keymap.set("n", "<Leader>su", "<cmd>Lazy update<CR>", { desc = "Update plugins" })

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
vim.keymap.set("n", "<Leader>so", source_config, { desc = "Source init.lua" })

-- Source the current config
local function source_current_config()
  local config_path = vim.fn.expand "%:p"
  load_config(config_path)
end
vim.keymap.set("n", "<Leader>sO", source_current_config, { desc = "Source current buffer" })

-- yank
local function copy_current_file_path()
  local path = vim.fn.expand "%:."
  vim.fn.setreg("*", path)
  vim.api.nvim_echo({ { "Copied: " .. path, "None" } }, true, {})
end
vim.keymap.set("n", "Yf", copy_current_file_path)

-- Copy file path with current line number
local function copy_file_path_with_line()
  local path = vim.fn.expand "%:."
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local text = path .. ":" .. line
  vim.fn.setreg("*", text)
  vim.api.nvim_echo({ { "Copied: " .. text, "None" } }, true, {})
end
vim.keymap.set("n", "Yl", copy_file_path_with_line)

-- Copy full path
local function copy_full_path()
  local path = vim.fn.expand "%:p"
  vim.fn.setreg("*", path)
  vim.api.nvim_echo({ { "Copied: " .. path, "None" } }, true, {})
end
vim.keymap.set("n", "YF", copy_full_path)

-- Copy directory path
local function copy_directory()
  local dir = vim.fn.expand "%:p:h"
  vim.fn.setreg("*", dir)
  vim.api.nvim_echo({ { "Copied: " .. dir, "None" } }, true, {})
end
vim.keymap.set("n", "Yd", copy_directory)

-- Copy relative directory path
local function copy_relative_directory()
  local dir = vim.fn.expand "%:.:h"
  vim.fn.setreg("*", dir)
  vim.api.nvim_echo({ { "Copied: " .. dir, "None" } }, true, {})
end
vim.keymap.set("n", "YD", copy_relative_directory)

-- ファイル名とバッファ内容をクリップボードにコピー
local function copy_buffer_with_path_and_code_block()
  local path = vim.fn.expand "%:."
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  local text = string.format("%s\n```\n%s\n```\n", path, content)
  vim.fn.setreg("*", text)
  vim.notify("Copied buffer: " .. path, vim.log.levels.INFO)
end
vim.keymap.set("n", "YY", copy_buffer_with_path_and_code_block)

-- Format keybindings (LSP-based)
vim.keymap.set("n", "<C-e>f", "<cmd>Format<CR>", { desc = "Format (auto-select)" })

-- Individual formatter keymaps
vim.keymap.set("n", "<C-e>b", "<cmd>FormatWithBiome<CR>", { desc = "Format with Biome" })
vim.keymap.set("n", "<C-e>p", "<cmd>FormatWithPrettier<CR>", { desc = "Format with Prettier" })
vim.keymap.set("n", "<C-e>e", "<cmd>FormatWithEslint<CR>", { desc = "Format with ESLint" })
vim.keymap.set("n", "<C-e>s", "<cmd>FormatWithTsLs<CR>", { desc = "Format with TypeScript" })
