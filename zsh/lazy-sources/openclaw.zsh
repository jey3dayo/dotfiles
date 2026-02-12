# OpenClaw completion (deferred loading)
# https://github.com/sasazame/openclaw

if (($ + commands[openclaw])); then
  source <(openclaw completion --shell zsh)
fi
