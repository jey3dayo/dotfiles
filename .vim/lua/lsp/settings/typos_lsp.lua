local config_dir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
return { init_options = { config = config_dir .. "/typos.toml" } }
