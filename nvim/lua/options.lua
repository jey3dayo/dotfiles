-- Clear all autocmds (from base.lua)
vim.cmd "autocmd!"
vim.scriptencoding = "utf-8"

-- ~/.cache/nvim
local cacheDir = vim.fn.stdpath "cache"

local options = {
  encoding = "utf-8",
  fileencoding = "utf-8",
  fileformats = { "unix", "mac", "dos" },
  display = "lastline",
  title = true,
  clipboard = "unnamedplus",
  cmdheight = 2,
  completeopt = { "menuone", "noselect" },
  conceallevel = 0,

  helplang = "ja",
  shell = "zsh",

  sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions",

  -- input
  autoindent = true,
  smartindent = true,

  -- search
  hlsearch = true,
  ignorecase = true,
  incsearch = true,
  smartcase = true,
  inccommand = "split",

  -- backup
  backup = true,
  swapfile = false,
  undofile = true,
  undolevels = 10000, -- より多くのundo履歴
  backupdir = cacheDir,
  directory = cacheDir,
  undodir = cacheDir,
  backupskip = { "/tmp/*", "/private/tmp/*", cacheDir },

  -- ui
  termguicolors = true,
  background = "dark",
  number = true,
  ruler = false,
  cursorline = false,
  ambiwidth = "single",

  -- visible SpecialKey
  list = true,
  listchars = "tab:>.,trail:-,extends:\\,eol:↴,space: ",

  -- tab width
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  expandtab = true,
  textwidth = 0,

  modelines = 0,
  showmatch = true,
  matchtime = 1,
  cursorcolumn = true,
  wildmenu = true,
  wildmode = "longest:full,full",
  laststatus = 3,
  lazyredraw = false,
  ttyfast = true,
  hidden = true,
  foldmethod = "marker",

  -- pum
  wildoptions = "pum",
  pumheight = 12,
  winblend = 20,
  pumblend = 20,
  signcolumn = "yes",
  wrap = false,

  -- fixed NVim
  ttimeout = true,
  ttimeoutlen = 50,

  -- performance
  updatetime = 250, -- 高速な補完とCursorHoldイベント
  timeoutlen = 300, -- キーシーケンスの高速化
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

local global_options = {
  loaded_ruby_provider = 0,
  loaded_node_provider = 0,
  loaded_perl_provider = 0,
  python3_host_prog = vim.fn.trim(vim.fn.system "mise where python") .. "/bin/python3",
}

for k, v in pairs(global_options) do
  vim.g[k] = v
end

vim.opt.shortmess:append "c"
vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]
