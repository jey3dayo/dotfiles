local M = {}

local uv = vim.uv or vim.loop
local tool_specs = {
  stylua = { install_name = "stylua", binary_relpath = "stylua" },
  prettier = { install_name = "npm-fsouza-prettierd", binary_relpath = "bin/prettier" },
  biome = { install_name = "biome", binary_relpath = "biome" },
  eslint_d = { install_name = "npm-eslint-d", binary_relpath = "bin/eslint_d" },
  ["markdownlint-cli2"] = {
    install_name = "npm-markdownlint-cli2",
    binary_relpath = "bin/markdownlint-cli2",
  },
  yamllint = { install_name = "yamllint", binary_relpath = "bin/yamllint" },
  shellcheck = { install_name = "shellcheck", binary_relpath = "shellcheck-v0.11.0/shellcheck" },
  hadolint = { install_name = "hadolint", binary_relpath = "hadolint" },
}

local function parse_install_version(version)
  local normalized = version:gsub("^v", "")
  local ok, parsed = pcall(vim.version.parse, normalized)
  if ok then return parsed end
  return nil
end

function M.latest_installed_binary(install_name, binary_relpath)
  if not uv or not uv.fs_scandir then return nil end

  local root = vim.fn.expand("~/.mise/installs/" .. install_name)
  local handle = uv.fs_scandir(root)
  if not handle then return nil end

  local candidates = {}
  while true do
    local name, kind = uv.fs_scandir_next(handle)
    if not name then break end
    if kind == "directory" then
      local candidate = root .. "/" .. name .. "/" .. binary_relpath
      if vim.fn.executable(candidate) == 1 then table.insert(candidates, { path = candidate, version = name }) end
    end
  end

  if vim.tbl_isempty(candidates) then return nil end

  table.sort(candidates, function(a, b)
    local a_parsed = parse_install_version(a.version)
    local b_parsed = parse_install_version(b.version)

    if a_parsed and b_parsed then return vim.version.lt(b_parsed, a_parsed) end
    return a.version > b.version
  end)

  local binary = candidates[1].path
  if vim.fn.executable(binary) == 1 then return binary end
  return nil
end

function M.resolve_command(cmd, opts)
  opts = opts or {}

  if not opts.install_name and not opts.binary_relpath then
    local spec = tool_specs[cmd]
    if spec then
      opts.install_name = spec.install_name
      opts.binary_relpath = spec.binary_relpath
    end
  end

  if opts.install_name and opts.binary_relpath then
    local latest = M.latest_installed_binary(opts.install_name, opts.binary_relpath)
    if latest then return latest end
  end

  local shim = vim.fn.expand("~/.mise/shims/" .. cmd)
  if vim.fn.executable(shim) == 1 then return shim end

  return cmd
end

return M
