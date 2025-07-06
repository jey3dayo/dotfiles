vim.g.mapleader = ","

local noremap_opts = { noremap = true, silent = true }
local silent_opts = { silent = true }

local function set_keymap(mode, key, value, opts)
  opts = opts or (mode == "n" and noremap_opts or silent_opts)
  vim.keymap.set(mode, key, value, opts)
end

function Keymap(key, value, opts)
  set_keymap("n", key, value, opts)
end

function I_Keymap(key, value, opts)
  set_keymap("i", key, value, opts)
end

function V_Keymap(key, value, opts)
  set_keymap("v", key, value, opts)
end

function X_Keymap(key, value, opts)
  set_keymap("x", key, value, opts)
end

function O_Keymap(key, value, opts)
  set_keymap("o", key, value, opts)
end

function T_Keymap(key, value, opts)
  set_keymap("t", key, value, opts)
end

-- deprecated
function Set_keymap(key, value, _opts)
  if not _opts then _opts = silent_opts end
  vim.api.nvim_set_keymap("n", key, value, _opts)
  vim.api.nvim_set_keymap("v", key, value, _opts)
end

function Buf_set_keymap(key, value, buf)
  vim.api.nvim_buf_set_keymap(buf, "n", key, value, noremap_opts)
end

Keymap("<C-d>", "<cmd>bd<CR>")
Keymap("<Tab>", "<cmd>wincmd w<CR>")
Keymap("gF", "0f v$gf")
Keymap("gF", "0f v$gf")

-- ESC ESC -> toggle hlsearch
Keymap("<Esc><Esc>", function()
  vim.cmd "set hlsearch!"
end)

-- LSP tag jump (modern replacement for ctags)
Keymap("tt", "<cmd>lua vim.lsp.buf.definition()<CR>", { desc = "Go to definition" })
Keymap("tj", "<cmd>lua vim.lsp.buf.references()<CR>", { desc = "Find references" })
Keymap("tk", "<cmd>lua vim.lsp.buf.implementation()<CR>", { desc = "Go to implementation" })
Keymap("tl", "<cmd>lua vim.lsp.buf.type_definition()<CR>", { desc = "Go to type definition" })

-- tab (direct mappings for mini.clue compatibility)
Keymap("<C-t>c", "<cmd>tabnew<CR>", { desc = "New tab" })
Keymap("<C-t>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
Keymap("<C-t>o", "<cmd>tab split<CR>", { desc = "Split tab" })
Keymap("<C-t>n", "<cmd>tabnext<CR>", { desc = "Next tab" })
Keymap("<C-t>p", "<cmd>tabprevious<CR>", { desc = "Previous tab" })

Keymap("gt", "<cmd>tabnext<CR>")
Keymap("gT", "<cmd>tabprevious<CR>")

-- set list
Keymap("<Leader>sn", "<cmd>set number!<CR>", { desc = "Toggle line numbers" })
Keymap("<Leader>sl", "<cmd>set list!<CR>", { desc = "Toggle list mode" })
Keymap("<Leader>sp", "<cmd>Lazy<CR>", { desc = "Plugin manager" })
Keymap("<Leader>sd", "<cmd>LspDebug<CR>", { desc = "LspDebug" })
Keymap("<Leader>sm", "<cmd>MasonUpdate<CR>", { desc = "Update Mason" })
Keymap("<Leader>st", "<cmd>TSUpdate all<CR>", { desc = "Update TreeSitter" })

-- update source
Keymap("<Leader>su", "<cmd>Lazy update<CR>", { desc = "Update plugins" })

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
Keymap("<Leader>so", source_config, { desc = "Source init.lua" })

-- Source the current config
local function source_current_config()
  local config_path = vim.fn.expand "%:p"
  load_config(config_path)
end
Keymap("<Leader>sO", source_current_config, { desc = "Source current buffer" })

-- yank
local function copy_current_file_path()
  local path = vim.fn.expand "%:."
  vim.fn.setreg("*", path)
  vim.api.nvim_echo({ { "Copied: " .. path, "None" } }, true, {})
end
Keymap("Yf", copy_current_file_path)

-- Copy file path with current line number
local function copy_file_path_with_line()
  local path = vim.fn.expand "%:."
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local text = path .. ":" .. line
  vim.fn.setreg("*", text)
  vim.api.nvim_echo({ { "Copied: " .. text, "None" } }, true, {})
end
Keymap("Yl", copy_file_path_with_line)

-- Copy full path
local function copy_full_path()
  local path = vim.fn.expand "%:p"
  vim.fn.setreg("*", path)
  vim.api.nvim_echo({ { "Copied: " .. path, "None" } }, true, {})
end
Keymap("YF", copy_full_path)

-- Copy directory path
local function copy_directory()
  local dir = vim.fn.expand "%:p:h"
  vim.fn.setreg("*", dir)
  vim.api.nvim_echo({ { "Copied: " .. dir, "None" } }, true, {})
end
Keymap("Yd", copy_directory)

-- Copy relative directory path
local function copy_relative_directory()
  local dir = vim.fn.expand "%:.:h"
  vim.fn.setreg("*", dir)
  vim.api.nvim_echo({ { "Copied: " .. dir, "None" } }, true, {})
end
Keymap("YD", copy_relative_directory)

-- ファイル名とバッファ内容をクリップボードにコピー
local function copy_buffer_with_path_and_code_block()
  local path = vim.fn.expand "%:."
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  local text = string.format("%s\n```\n%s\n```\n", path, content)
  vim.fn.setreg("*", text)
  vim.notify("Copied buffer: " .. path, vim.log.levels.INFO)
end
Keymap("YY", copy_buffer_with_path_and_code_block)


-- Format keybindings (LSP-based)
Keymap("<C-e>f", "<cmd>Format<CR>", { desc = "Format (auto-select)" })

-- Individual formatter keymaps
Keymap("<C-e>b", "<cmd>FormatWithBiome<CR>", { desc = "Format with Biome" })
Keymap("<C-e>p", "<cmd>FormatWithPrettier<CR>", { desc = "Format with Prettier" })
Keymap("<C-e>e", "<cmd>FormatWithEslint<CR>", { desc = "Format with ESLint" })
Keymap("<C-e>s", "<cmd>FormatWithTsLs<CR>", { desc = "Format with TypeScript" })
Keymap("<C-e>m", "<cmd>FormatWithEfm<CR>", { desc = "Format with EFM" })

-- Experimental: Telescope with <Leader>f prefix
-- These work alongside existing keymaps due to timeoutlen
-- 慣れたら<leader>f[] に統一することを検討
Keymap("<Leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
Keymap("<Leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
Keymap("<Leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Find buffers" })
Keymap("<Leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help" })
Keymap("<Leader>fo", "<cmd>Telescope oldfiles<cr>", { desc = "Find old files" })
Keymap("<Leader>fc", "<cmd>Telescope commands<cr>", { desc = "Find commands" })
Keymap("<Leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps" })
Keymap("<Leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Find symbols" })
Keymap("<Leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Find diagnostics" })
