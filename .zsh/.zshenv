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
  export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

# perl
if [ -d $USERDIR/perl5 ] ; then
  export PERL_LOCAL_LIB_ROOT="$USERDIR/perl5:$PERL_LOCAL_LIB_ROOT";
  export PERL_MB_OPT="--install_base "$USERDIR/perl5"";
  export PERL_MM_OPT="INSTALL_BASE=$USERDIR/perl5";
  export PERL5LIB="$USERDIR/perl5/lib/perl5:$PERL5LIB";
  export PATH="$USERDIR/perl5/bin:$PATH";
fi


# android
if [ -d /usr/local/opt/android-sdk ] ; then
  export ANDROID_HOME=/usr/local/opt/android-sdk
  export NDK_ROOT=/usr/local/Cellar/android-ndk/r9d
  export ANDROID_SDK_ROOT=/usr/local/opt/android-sdk
  export ANT_ROOT=/usr/local/bin
fi


# rbenv path
if [ -d ${HOME}/.rbenv ] ; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  export MANPATH=/opt/local/man:$MANPATH
  export RAILS_ENV="development"
  eval "$(rbenv init - zsh)"
fi


if [ -d ${HOME}/.plenv ] ; then
  export PATH="$HOME/.plenv/bin:$PATH"
  eval "$(plenv init - zsh)"
fi


# python
export PATH=$PATH:~/Library/Python/2.7/bin


# go lang
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin


# percol
if [[ -s ~/.zsh/load_plugins.zsh ]] ; then source ~/.zsh/load_plugins.zsh ; fi


# java
export JAVA_OPTS="-Djava.net.useSystemProxies=true"
export CATALINA_HOME=/usr/local/Cellar/tomcat/latest/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore

# jenv
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

typeset -U path cdpath fpath manpath
