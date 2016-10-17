path=(
    /usr/local/bin(N-/)
    /usr/local/sbin(N-/)
    $HOME/bin(N-/)
    $HOME/sbin(N-/)
    $HOME/local/bin(N-/)
    $path
)

if [ -d /usr/local/var/nodebrew ] ; then
  export NODEBREW_ROOT=/usr/local/var/nodebrew
  path=($NODEBREW_ROOT/current/bin(N-/) $path)
fi

export GOPATH=$HOME
path=($GOPATH/bin(N-/) $path)

# java
export JAVA_OPTS="-Djava.net.useSystemProxies=true"
export CATALINA_HOME=/usr/local/Cellar/tomcat/latest/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore
typeset -U path cdpath fpath manpath

# GHQ
export GHQ_ROOT=~/src

# yarn
if [ -d $HOME/.yarn/bin/ ] ; then
  path=($HOME/.yarn/bin(N-/) $path)
fi

