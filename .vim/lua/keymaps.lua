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

Keymap("<C-d>", ":<C-u>bd<CR>")
Keymap("<Tab>", ":<C-u>wincmd w<CR>")
Keymap("gF", "0f v$gf")
Keymap("gF", "0f v$gf")

-- ESC ESC -> toggle hlsearch
Keymap("<Esc><Esc>", ":<C-u>set hlsearch!<CR>")

-- link jump
Keymap("t", "<Nop>")
Keymap("tt", "<C-]>")
Keymap("tj", ":<C-u>tag<CR>")
Keymap("tk", ":<C-u>pop<CR>")

-- tab
Keymap("<C-t>", "<Nop>")
Keymap("<C-t>c", ":<C-u>tabnew<CR>")
Keymap("<C-t>d", ":<C-u>tabclose<CR>")
Keymap("<C-t>o", ":<C-u>tabonly<CR>")
Keymap("<C-t>n", ":<C-u>tabnext<CR>")
Keymap("<C-t>p", ":<C-u>tabprevious<CR>")
Keymap("gt", ":<C-u>tabnext<CR>")
Keymap("gT", ":<C-u>tabprevious<CR>")

-- set list
Keymap("<Leader>sn", ":<C-u>set number!<CR>")
Keymap("<Leader>sl", ":<C-u>set list!<CR>")
Keymap("<leader><C-d>", ":<C-u>bd!<CR>")

-- update source
Keymap("<Leader>su", ":<C-u>Lazy update<CR>")

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
