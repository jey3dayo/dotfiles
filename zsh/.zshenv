export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"

if [[ "$SHLVL" -eq 1 && -s "${ZDOTDIR}/.zshenv.local" ]]; then
  source "${ZDOTDIR}/.zshenv.local"
fi

export GHQ_ROOT=~/src
export GOPATH=$HOME

export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/.ripgreprc"

# AWSume alias to source the AWSume script
alias awsume="source \$(pyenv which awsume)"
fpath=(~/.awsume/zsh-autocomplete/ $fpath)

export DIRENV_WARN_TIMEOUT=60s

export _FASD_DATA="$XDG_CACHE_HOME/fasd/.fasd"

export BUN_INSTALL="$HOME/.bun"

path=(
  /usr/local/opt/openjdk/bin:(N-/)
  /usr/local/opt/coreutils/libexec/gnubin(N-/)
  $HOME/.local/{bin,sbin}(N-/)
  /usr/local/{bin,sbin}(N-/)
  $HOME/.deno/bin(N-/)
  $HOME/.cargo/bin(N-/)
  /opt/homebrew/{bin,sbin}(N-/)
  $GOPATH/bin(N-/)
  $BUN_INSTALL/bin(N-/)
  $path
)


# vim: set syntax=zsh:
