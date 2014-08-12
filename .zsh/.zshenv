# rbenv path
export MANPATH=/opt/local/man:$MANPATH

path=(
    /usr/local/bin(N-/)
    /usr/local/sbin(N-/)
    $HOME/bin(N-/)
    $HOME/sbin(N-/)
    $HOME/local/bin(N-/)
    $HOME/.rbenv/versions/1.9.3-p429/bin(N-/)
    /usr/local/wine/bin(N-/)
    /usr/local/lib/ruby/gems/2.1.0/gems/tmuxinator-0.6.7/bin(N-/)
    $HOME/.go(N-/)
    $path
)

if [ -d ${HOME}/.rbenv ] ; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  # eval "$(rbenv init -)"
  eval "$(rbenv init - zsh)"
fi
