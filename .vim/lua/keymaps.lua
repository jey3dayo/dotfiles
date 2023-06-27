vim.g.mapleader = ","

local noremap_opts = { noremap = true, silent = true }
local silent_opts = { silent = true }

function Keymap(key, value, _opts)
  if _opts then
    noremap_opts = _opts
  end
  vim.keymap.set("n", key, value, noremap_opts)
end

function I_Keymap(key, value, _opts)
  if _opts then
    silent_opts = _opts
  end
  vim.keymap.set("i", key, value, silent_opts)
end

function Set_keymap(key, value, _opts)
  if _opts then
    noremap_opts = _opts
  end
  vim.api.nvim_set_keymap("n", key, value, noremap_opts)
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

-- source cmd
Keymap("<Leader>so", ":<C-u>source " .. vim.fn.stdpath "config" .. "/init.lua<CR>")
Keymap("<Leader>su", ":<C-u>Lazy update<CR>")

-- set list
Keymap("<Leader>sn", ":<C-u>set number!<CR>")
Keymap("<Leader>sl", ":<C-u>set list!<CR>")
Keymap("<leader><C-d>", ":<C-u>bd!<CR>")
