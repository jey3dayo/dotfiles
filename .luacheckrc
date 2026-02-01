-- .luacheckrc
-- Luacheck configuration for Neovim Lua files

-- Global vim namespace
globals = {
  "vim",
}

-- Read-only globals (for busted testing framework)
read_globals = {
  "describe",
  "it",
  "before_each",
  "after_each",
  "pending",
  "assert",
  "spy",
  "mock",
  "stub",
}

-- Ignore specific warnings
ignore = {
  "211", -- Unused local variable
  "212", -- Unused argument
  "213", -- Unused loop variable
  "631", -- Line is too long
}

-- Exclude directories
exclude_files = {
  "lua/plugins/",
  ".luarocks/",
  ".git/",
}
