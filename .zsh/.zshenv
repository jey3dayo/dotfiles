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


case ${OSTYPE} in
  darwin*)
  USERDIR="/Users/`whoami`"
  if command -v brew>/dev/null; then source $(brew --prefix nvm)/nvm.sh ; fi

  # Add environment variable NDK_ROOT for cocos2d-x
  export NDK_ROOT=/usr/local/Cellar/android-ndk-r9d/r9d
  export PATH=$NDK_ROOT:$PATH

  # Add environment variable ANDROID_SDK_ROOT for cocos2d-x
  export ANDROID_SDK_ROOT=/usr/local/Cellar/android-sdk/24.3.2
  export PATH=$ANDROID_SDK_ROOT:$PATH
  export PATH=$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH

  # Add environment variable ANT_ROOT for cocos2d-x
  export ANT_ROOT=/usr/local/Cellar/ant/1.9.5/libexec/bin
  export PATH=$ANT_ROOT:$PATH

  # Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
  export COCOS_CONSOLE_ROOT=/Users/t00114/Documents/Github/cocos2d-x/tools/cocos2d-console/bin
  export PATH=$COCOS_CONSOLE_ROOT:$PATH
  ;;
  linux*)
  USERDIR="/home/`whoami`"
  if [[ -s ~/nvm/nvm.sh ]] ; then source ~/nvm/nvm.sh ; fi
  ;;
esac


# perl
export PERL_LOCAL_LIB_ROOT="$USERDIR/perl5:$PERL_LOCAL_LIB_ROOT";
export PERL_MB_OPT="--install_base "$USERDIR/perl5"";
export PERL_MM_OPT="INSTALL_BASE=$USERDIR/perl5";
export PERL5LIB="$USERDIR/perl5/lib/perl5:$PERL5LIB";
export PATH="$USERDIR/perl5/bin:$PATH";


# android
export ANDROID_HOME=/usr/local/opt/android-sdk
export NDK_ROOT=/usr/local/Cellar/android-ndk/r9d
export ANDROID_SDK_ROOT=/usr/local/opt/android-sdk
export ANT_ROOT=/usr/local/bin


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
