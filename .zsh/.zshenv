path=(
    /usr/local/bin(N-/)
    /usr/local/sbin(N-/)
    $HOME/bin(N-/)
    $HOME/sbin(N-/)
    $HOME/local/bin(N-/)
    $path
)

if [ -d $USERDIR/.nodebrew ] ; then
  export NODEBREW_ROOT=/usr/local/var/nodebrew
  path=($HOME/.nodebrew/current/bin(N-/) $path)
fi

if [ -d $USERDIR/perl5 ] ; then
  export PERL_LOCAL_LIB_ROOT="$USERDIR/perl5:$PERL_LOCAL_LIB_ROOT";
  export PERL_MB_OPT="--install_base "$USERDIR/perl5"";
  export PERL_MM_OPT="INSTALL_BASE=$USERDIR/perl5";
  export PERL5LIB="$USERDIR/perl5/lib/perl5:$PERL5LIB";
  path=($USERDIR/perl5/bin(N-/) $path)
fi

# android
if [ -d /usr/local/opt/android-sdk ] ; then
  export ANDROID_HOME=/usr/local/opt/android-sdk
  export NDK_ROOT=/usr/local/Cellar/android-ndk/r9d
  export ANDROID_SDK_ROOT=/usr/local/opt/android-sdk
  export ANT_ROOT=/usr/local/bin
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
