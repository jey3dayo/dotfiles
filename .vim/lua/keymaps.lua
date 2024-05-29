vim.g.mapleader = ","

local noremap_opts = { noremap = true, silent = true }
local silent_opts = { silent = true }

function Keymap(key, value, _opts)
  if not _opts then
    _opts = noremap_opts
  end
  vim.keymap.set("n", key, value, _opts)
end

function I_Keymap(key, value, _opts)
  if not _opts then
    _opts = silent_opts
  end
  vim.keymap.set("i", key, value, _opts)
end

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
-- Keymap("t", "<Nop>")
-- Keymap("tt", "<C-]>")
-- Keymap("tj", ":<C-u>tag<CR>")
-- Keymap("tk", ":<C-u>pop<CR>")

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

-- source config
local function source_config()
  local config_path = vim.fn.stdpath "config" .. "/init.lua"
  vim.cmd("source " .. config_path)
  vim.api.nvim_echo({ { "Loaded config: " .. config_path, "None" } }, true, {})
end
Keymap("<Leader>so", source_config)

-- yank
local function copy_path()
  local path = vim.fn.expand "%:."
  vim.fn.setreg("*", path)
  vim.api.nvim_echo({ { "Copied: " .. path, "None" } }, true, {})
end
Keymap("<Leader>y", copy_path)
