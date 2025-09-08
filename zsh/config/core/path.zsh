path=(
  $HOME/{bin,sbin}(N-/)
  $HOME/.local/{bin,sbin}(N-/)
  # System and existing PATH first
  $path
  # Homebrew paths added to end - mise tools will take priority via deferred activation
  /opt/homebrew/{bin,sbin}(N-/)
)
