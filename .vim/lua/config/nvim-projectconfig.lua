local config_dir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
return { project_dir = config_dir .. "/projects-config/", silent = false }
