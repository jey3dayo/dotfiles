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

function T_Keymap(key, value, opts)
  set_keymap("t", key, value, opts)
end

-- deprecated
function Set_keymap(key, value, _opts)
  if not _opts then _opts = silent_opts end
  vim.api.nvim_set_keymap("n", key, value, _opts)
  vim.api.nvim_set_keymap("v", key, value, _opts)
end

function Buf_set_keymap(key, value, buf)
  vim.api.nvim_buf_set_keymap(buf, "n", key, value, noremap_opts)
end

Keymap("<C-d>", "<cmd>bd<CR>")
Keymap("<Tab>", "<cmd>wincmd w<CR>")
Keymap("gF", "0f v$gf")
Keymap("gF", "0f v$gf")

-- ESC ESC -> toggle hlsearch, clear notify
Keymap("<Esc><Esc>", function()
  vim.cmd "set hlsearch!"
  vim.cmd "Noice dismiss"
end)

-- link jump
Set_keymap("[tag]", "<Nop>", {})
Set_keymap("t", "[tag]", {})
Keymap("[tag]t", "<C-]>")
Keymap("[tag]j", "<cmd>tag<CR>")
Keymap("[tag]k", "<cmd>pop<CR>")

-- tab
Set_keymap("[tab]", "<Nop>", {})
Set_keymap("<C-t>", "[tab]", {})
Keymap("[tab]c", "<cmd>tabnew<CR>")
Keymap("[tab]d", "<cmd>tabclose<CR>")
Keymap("[tab]o", "<cmd>tab split<CR>")
Keymap("[tab]n", "<cmd>tabnext<CR>")
Keymap("[tab]p", "<cmd>tabprevious<CR>")

Keymap("gt", "<cmd>tabnext<CR>")
Keymap("gT", "<cmd>tabprevious<CR>")

-- set list
Keymap("<Leader>sn", "<cmd>set number!<CR>")
Keymap("<Leader>sl", "<cmd>set list!<CR>")
Keymap("<leader><C-d>", "<cmd>bd!<CR>")

-- update source
Keymap("<Leader>su", "<cmd>Lazy update<CR>")

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
Keymap("Yf", copy_current_file_path)

-- ファイル名とバッファ内容をクリップボードにコピー
local function copy_buffer_with_path_and_code_block()
  local path = vim.fn.expand "%:."
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, "\n")
  local text = string.format("%s\n```\n%s\n```\n", path, content)
  vim.fn.setreg("*", text)
  vim.notify("Copied buffer: " .. path, vim.log.levels.INFO)
end
Keymap("YY", copy_buffer_with_path_and_code_block)

-- Copy GitHub URL for current file and line/range
local function copy_github_url()
  -- Get git remote URL
  local handle = io.popen "git remote get-url origin 2>/dev/null"
  if not handle then
    vim.notify("Failed to open remote handle", vim.log.levels.ERROR)
    return
  end
  local remote_url = handle:read("*a"):gsub("\n", "")
  handle:close()

  if remote_url == "" then
    vim.notify("Not in git repository", vim.log.levels.WARN)
    return
  end

  -- Convert SSH URL to HTTPS if needed
  remote_url = remote_url:gsub("git@github%.com:", "https://github.com/")
  remote_url = remote_url:gsub("%.git$", "")

  -- Get current branch
  local branch_handle = io.popen "git branch --show-current 2>/dev/null"
  if not branch_handle then
    vim.notify("Failed to open branch handle", vim.log.levels.ERROR)
    return
  end

  local branch = branch_handle:read("*a"):gsub("\n", "")
  branch_handle:close()

  if branch == "" then
    vim.notify("Could not get git branch", vim.log.levels.WARN)
    return
  end

  -- Get relative file path from git root
  local file_handle = io.popen("git ls-files --full-name " .. vim.fn.shellescape(vim.fn.expand "%") .. " 2>/dev/null")
  if not file_handle then
    vim.notify("Failed to open file handle", vim.log.levels.ERROR)
    return
  end
  local file_path = file_handle:read("*a"):gsub("\n", "")
  file_handle:close()

  if file_path == "" then
    vim.notify("File not tracked by git", vim.log.levels.WARN)
    return
  end

  -- Get line numbers (handle visual mode range)
  local start_line, end_line
  local mode = vim.fn.mode()

  if mode == "v" or mode == "V" or mode == "\22" then -- Visual modes
    -- Get visual selection range
    start_line = vim.fn.line "'<"
    end_line = vim.fn.line "'>"
  else
    -- Normal mode - current line
    start_line = vim.api.nvim_win_get_cursor(0)[1]
    end_line = start_line
  end

  -- Construct GitHub URL with line range
  local github_url, line_info
  if start_line == end_line then
    github_url = string.format("%s/blob/%s/%s#L%d", remote_url, branch, file_path, start_line)
    line_info = "L" .. start_line
  else
    github_url = string.format("%s/blob/%s/%s#L%d-L%d", remote_url, branch, file_path, start_line, end_line)
    line_info = "L" .. start_line .. "-L" .. end_line
  end

  vim.fn.setreg("*", github_url)
  vim.notify("Copied GitHub URL: " .. line_info, vim.log.levels.INFO)
end

Keymap("Yg", copy_github_url)
V_Keymap("Yg", copy_github_url)

-- Format keybindings
Keymap("<C-e>f", "<cmd>Format<CR>", { desc = "Format file (LSP)" })

-- Prettier formatting
Keymap("<C-e>p", function()
  vim.cmd("!prettier --write " .. vim.fn.expand "%")
  vim.cmd "edit!"
end, { desc = "Format with Prettier" })

-- Biome formatting
Keymap("<C-e>b", function()
  vim.cmd("!biome format --write " .. vim.fn.expand "%")
  vim.cmd "edit!"
end, { desc = "Format with Biome" })
