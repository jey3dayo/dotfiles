local keymap = vim.keymap.set

local opts = { noremap = true, silent = true }
-- local term_opts = { silent = true }

vim.g.mapleader = ","

keymap("n", "<C-d>", ":<C-u>bd<CR>", opts)
keymap("n", "<Tab>", ":<C-u>wincmd w<CR>", opts)
keymap("n", "gF", "0f v$gf", opts)
keymap("n", "gF", "0f v$gf", opts)

-- ESC ESC -> toggle hlsearch
keymap("n", "<Esc><Esc>", ":<C-u>set hlsearch!<CR>", opts)

-- link jump
keymap("n", "t", "<Nop>", opts)
keymap("n", "tt", "<C-]>", opts)
keymap("n", "tj", ":<C-u>tag<CR>", opts)
keymap("n", "tk", ":<C-u>pop<CR>", opts)

-- tab
keymap("n", "<C-t>", "<Nop>", opts)
keymap("n", "<C-t>c", ":<C-u>tabnew<CR>", opts)
keymap("n", "<C-t>d", ":<C-u>tabclose<CR>", opts)
keymap("n", "<C-t>o", ":<C-u>tabonly<CR>", opts)
keymap("n", "<C-t>n", ":<C-u>tabnext<CR>", opts)
keymap("n", "<C-t>p", ":<C-u>tabprevious<CR>", opts)
keymap("n", "gt", ":<C-u>tabnext<CR>", opts)
keymap("n", "gT", ":<C-u>tabprevious<CR>", opts)

-- source cmd
keymap("n", "<Leader>so", ":<C-u>source ~/.vimrc<CR>", opts)
keymap("n", "<Leader>su", ":<C-u>Lazy update<CR>", opts)

-- set list
keymap("n", "<Leader>sn", ":<C-u>set number!<CR>", opts)
keymap("n", "<Leader>sl", ":<C-u>set list!<CR>", opts)
