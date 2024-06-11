local project_config = safe_require "nvim-projectconfig"

if not project_config then
  return
end

project_config.setup {
  project_dir = "~/.config/projects-config/",
  silent = false,
}
