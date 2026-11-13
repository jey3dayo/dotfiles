# Route Codex through the agmsg bridge when the bridge is installed.
if [[ -x "${HOME}/.agents/skills/agmsg/scripts/drivers/types/codex/codex-shim.sh" ]]; then
  codex() {
    "${HOME}/.agents/skills/agmsg/scripts/drivers/types/codex/codex-shim.sh" "$@"
  }
fi

# vim: set syntax=zsh:
