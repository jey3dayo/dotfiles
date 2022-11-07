path=(
  /usr/local/opt/openjdk/bin:(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  $HOME/.local/{bin,sbin}(N-/)
  /usr/local/{bin,sbin}(N-/)
  $HOME/.deno/bin(N-/)
  /opt/homebrew/{bin,sbin}(N-/)
  $path
)

# Temporary Files
if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
