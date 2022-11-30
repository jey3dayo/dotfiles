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
