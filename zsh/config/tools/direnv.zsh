# direnv - load/unload environment variables based on directory
# https://direnv.net

if (($ + commands[direnv])); then
  eval "$(direnv hook zsh)"
fi
