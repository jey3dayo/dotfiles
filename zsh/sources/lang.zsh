if [ -d $HOME/perl5 ] ; then
  export PERL_LOCAL_LIB_ROOT="$HOME/perl5:$PERL_LOCAL_LIB_ROOT"
  export PERL_MB_OPT="--install_base "$HOME/perl5""
  export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
  export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
  path=($HOME/perl5/bin(N-/) $path)
fi

path=("$HOME/.cargo/bin/"(N-/) $path)

# export JAVA_HOME=`/usr/libexec/java_home -v 1.8.0`
export JAVA_HOME=`/usr/libexec/java_home -v 18`
export STUDIO_JDK=${JAVA_HOME%/*/*}

export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
path=(
  $ANDROID_SDK_ROOT/emulator(N-/)
  $ANDROID_SDK_ROOT/tools(N-/)
  $ANDROID_SDK_ROOT/tools/bin(N-/)
  $ANDROID_SDK_ROOT/platform-tools(N-/)
  $path)

export JAVA_OPTS="-Djava.net.useSystemProxies=true"
# export CATALINA_HOME=/opt/homebrew/Cellar/tomcat/latest/libexec/
export CATALINA_HOME=/opt/homebrew/Cellar/tomcat/10.1.1/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore

export GOPATH=$HOME
