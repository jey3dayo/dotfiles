path=(
    /usr/local/bin(N-/)
    /usr/local/sbin(N-/)
    $HOME/bin(N-/)
    $HOME/sbin(N-/)
    $HOME/local/bin(N-/)
    $path
)


case ${OSTYPE} in
  darwin*)
  USERDIR="/Users/`whoami`"
  if command -v brew>/dev/null; then source $(brew --prefix nvm)/nvm.sh ; fi
  ;;
  linux*)
  USERDIR="/home/`whoami`"
  if [[ -s ~/nvm/nvm.sh ]] ; then source ~/nvm/nvm.sh ; fi
  ;;
esac


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



# go lang
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin


# percol
if [[ -s ~/.zsh/load_plugins.zsh ]] ; then source ~/.zsh/load_plugins.zsh ; fi

# java
export JAVA_OPTS="-Djava.net.useSystemProxies=true"

typeset -U path cdpath fpath manpath
