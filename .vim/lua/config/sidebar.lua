local sidebar = safe_require "sidebar-nvim"
if not sidebar then
  return
end
sidebar.setup { open = false, bindings = {} }
