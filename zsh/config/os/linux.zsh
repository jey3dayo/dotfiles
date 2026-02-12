# Linux-specific configuration

# CUDA toolkit (if installed)
if [[ -d /usr/local/cuda ]]; then
  export PATH="/usr/local/cuda/bin${PATH:+:${PATH}}"
  export LD_LIBRARY_PATH="/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi

# WSL2-specific settings
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # Use wslview for WSL browser integration (opens Windows default browser)
  if (($ + commands[wslview])); then
    export BROWSER=wslview
  fi
fi
