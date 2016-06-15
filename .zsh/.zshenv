path=(
    /usr/local/bin(N-/)
    /usr/local/sbin(N-/)
    $HOME/bin(N-/)
    $HOME/sbin(N-/)
    $HOME/local/bin(N-/)
    $path
)

if [ -d $HOME/.nodebrew ] ; then
  export NODEBREW_ROOT=/usr/local/var/nodebrew
  path=($HOME/.nodebrew/current/bin(N-/) $path)
fi

if [ -d $HOME/perl5 ] ; then
  export PERL_LOCAL_LIB_ROOT="$HOME/perl5:$PERL_LOCAL_LIB_ROOT";
  export PERL_MB_OPT="--install_base "$HOME/perl5"";
  export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
  export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB";
  path=($HOME/perl5/bin(N-/) $path)
fi

if [ -d ${HOME}/.plenv ] ; then
  path=($HOME/.plenv/bin(N-/) $path)
  eval "$(plenv init - zsh)"
fi

path=(~/Library/Python/2.7/bin(N-/) $path)

if which jenv > /dev/null; then eval "$(jenv init -)"; fi

export GOPATH=$HOME
path=($GOPATH/bin(N-/) $path)

# percol
if [[ -s ~/.zsh/load_plugins.zsh ]] ; then source ~/.zsh/load_plugins.zsh ; fi

# java
export JAVA_OPTS="-Djava.net.useSystemProxies=true"
export CATALINA_HOME=/usr/local/Cellar/tomcat/latest/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore

typeset -U path cdpath fpath manpath
