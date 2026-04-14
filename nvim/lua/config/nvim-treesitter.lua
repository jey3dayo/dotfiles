local M = {}

local treesitter_aliases = {
  bash = { "sh", "zsh" },
  javascript = { "javascriptreact" },
  tsx = { "typescriptreact" },
}

local function register_language_aliases()
  local language = vim.treesitter and vim.treesitter.language
  if not language or type(language.register) ~= "function" then return end

  for lang, filetypes in pairs(treesitter_aliases) do
    pcall(language.register, lang, filetypes)
  end
end

local function install_missing_parsers()
  local ok, treesitter = pcall(require, "nvim-treesitter")
  if not ok then return end

  local wanted = require("lsp.config").installed_tree_sitter
  local available = {}
  local installed = {}

  for _, lang in ipairs(treesitter.get_available()) do
    available[lang] = true
  end

  for _, lang in ipairs(treesitter.get_installed "parsers") do
    installed[lang] = true
  end

  local missing = {}
  for _, lang in ipairs(wanted) do
    if available[lang] and not installed[lang] then table.insert(missing, lang) end
  end

  if #missing > 0 then treesitter.install(missing, { summary = true }) end
end

function M.setup()
  local ok, treesitter = pcall(require, "nvim-treesitter")
  if not ok then return end

  treesitter.setup {}
  register_language_aliases()
  install_missing_parsers()
end

return M
