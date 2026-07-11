# Inject a GitHub token only for mise commands that hit the GitHub API,
# to avoid unauthenticated rate limits (60 req/h).
mise() {
  emulate -L zsh
  case "$1" in
    bootstrap | install | outdated | update | upgrade | use)
      local token
      token="$(command gh auth token 2> /dev/null)"
      if [[ -n "$token" ]]; then
        MISE_GITHUB_TOKEN="$token" command mise "$@"
      else
        command mise "$@"
      fi
      ;;
    *)
      command mise "$@"
      ;;
  esac
}

# vim: set syntax=zsh:
