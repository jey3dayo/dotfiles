local M = {}

function M.ensure_tools()
  local ok_config, lsp_config = pcall(require, "lsp.config")
  if not ok_config or not lsp_config.mason_tools or not lsp_config.mason_tools.ensure_installed then return end

  local ok_registry, registry = pcall(require, "mason-registry")
  if not ok_registry then return end

  for _, name in ipairs(lsp_config.mason_tools.ensure_installed) do
    local ok_pkg, pkg = pcall(registry.get_package, name)
    if ok_pkg and not pkg:is_installed() then pkg:install() end
  end
end

return M
