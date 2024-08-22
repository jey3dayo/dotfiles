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
  if not _opts then
    _opts = silent_opts
  end
  vim.api.nvim_set_keymap("n", key, value, _opts)
end

function Buf_set_keymap(key, value, buf)
  vim.api.nvim_buf_set_keymap(buf, "n", key, value, noremap_opts)
end

Keymap("<C-d>", "<cmd>bd<CR>")
Keymap("<Tab>", "<cmd>wincmd w<CR>")
Keymap("gF", "0f v$gf")
Keymap("gF", "0f v$gf")

-- ESC ESC -> toggle hlsearch
Keymap("<Esc><Esc>", "<cmd>set hlsearch!<CR>")

-- link jump
Set_keymap("[tag]", "<Nop>", {})
Set_keymap("t", "[tag]", {})
Keymap("[tag]t", "<C-]>")
Keymap("[tag]j", "<cmd>tag<CR>")
Keymap("[tag]k", "<cmd>pop<CR>")

-- tab
Set_keymap("[tab]", "<Nop>", {})
Set_keymap("<C-t>", "[tab]", {})
Keymap("[tab]c", "<cmd>tabnew<CR>")
Keymap("[tab]d", "<cmd>tabclose<CR>")
Keymap("[tab]o", "<cmd>tabonly<CR>")
Keymap("[tab]n", "<cmd>tabnext<CR>")
Keymap("[tab]p", "<cmd>tabprevious<CR>")

Keymap("gt", "<cmd>tabnext<CR>")
Keymap("gT", "<cmd>tabprevious<CR>")

-- set list
Keymap("<Leader>sn", "<cmd>set number!<CR>")
Keymap("<Leader>sl", "<cmd>set list!<CR>")
Keymap("<leader><C-d>", "<cmd>bd!<CR>")

-- update source
Keymap("<Leader>su", "<cmd>Lazy update<CR>")

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
Keymap("<Leader>y", copy_current_file_path)

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
