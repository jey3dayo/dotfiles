# export ZDOTDIR=~/src/github.com/j138/dotfiles/.zsh
if [[ "$SHLVL" -eq 1 && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

export XDG_CONFIG_HOME="$HOME/.config"

export JAVA_OPTS="-Djava.net.useSystemProxies=true"
export CATALINA_HOME=/usr/local/Cellar/tomcat/latest/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore
typeset -U path cdpath fpath manpath

if [ -d $HOME/perl5 ] ; then
  export PERL_LOCAL_LIB_ROOT="$HOME/perl5:$PERL_LOCAL_LIB_ROOT"
  export PERL_MB_OPT="--install_base "$HOME/perl5""
  export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
  export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
  path=($HOME/perl5/bin(N-/) $path)
fi

export GOPATH=$HOME
export GHQ_ROOT=~/src

path=(
  "$HOME/.pyenv/shims"(N-/)
  "$HOME/Library/Python/2.7/bin/"(N-/)
  $path
)
