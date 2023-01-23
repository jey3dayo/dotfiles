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
  swapfile = true,
  undofile = true,
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
  -- scrolloff = 8,
  -- sidescrolloff = 8,
  -- TODO: East Asian Ambigous Width
  ambiwidth = "single",

  -- visible SpecialKey
  list = true,
  listchars = "tab:>.,trail:-,extends:\\",

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
  laststatus = 2,
  lazyredraw = true,
  ttyfast = true,
  shellslash = true,
  hidden = true,
  foldmethod = "marker",

  -- pum
  wildoptions = "pum",
  pumheight = 12,
  -- winblend = 20,
  -- pumblend = 20,

  -- fixed NVim
  ttimeout = true,
  ttimeoutlen = 50,

  -- TODO: uncheck
  -- showmode = false,
  -- showtabline = 2,
  -- timeoutlen = 300,
  -- updatetime = 300,
  -- relativenumber = false,
  -- signcolumn = "yes",
  -- wrap = false,
}

vim.opt.shortmess:append("c")

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd("set whichwrap+=<,>,[,],h,l")
vim.cmd([[set iskeyword+=-]])
