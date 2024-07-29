vim.cmd [[
try
  colorscheme kanagawa

  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight SpecialKey ctermbg=NONE guibg=NONE
  highlight EndOfBuffer ctermbg=NONE guibg=NONE

  " custom
  highlight SignColumn ctermbg=NONE guibg=NONE
  highlight NormalNC ctermbg=NONE guibg=NONE
  highlight TelescopeBorder ctermbg=NONE guibg=NONE
  highlight NvimTreeNormal ctermbg=NONE guibg=NONE
  highlight MsgArea ctermbg=NONE guibg=NONE

catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
