local autocmd = vim.api.nvim_create_autocmd
local _augroup = vim.api.nvim_create_augroup

local function augroup(group_name)
  _augroup(group_name, { clear = true })
end

autocmd({ "BufNewFile", "BufRead" }, { pattern = { ".envrc" }, command = 'set filetype=bash' })
autocmd({ "BufNewFile", "BufRead" }, { pattern = { ".env*" }, command = 'set filetype=sh' })
autocmd({ "BufNewFile", "BufRead" }, { pattern = { ".ts.bk" }, command = 'set filetype=typescript.tsx' })

autocmd("BufWritePre", {
  pattern = "*",
  command = 'let v:swapchoice = "o"',
})

-- Remove whitespace on save
autocmd("BufWritePre", {
  pattern = "*",
  command = ":%s/\\s\\+$//e",
})

-- Don't auto commenting new lines
autocmd("BufEnter", {
  pattern = "*",
  command = "set fo-=c fo-=r fo-=o",
})

-- Restore cursor location when file is opened
autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    vim.api.nvim_exec('silent! normal! g`"zv', false)
  end,
})

augroup("highlightIdegraphicSpace")

autocmd({ "VimEnter", "Colorscheme" }, {
  pattern = "*",
  group = "highlightIdegraphicSpace",
  command = "highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen",
  desc = "highlight Zenakaku Space",
})

autocmd({ "VimEnter", "WinEnter" }, {
  pattern = "*",
  group = "highlightIdegraphicSpace",
  command = "match IdeographicSpace /　/",
  desc = "highlight Zenakaku Space",
})
