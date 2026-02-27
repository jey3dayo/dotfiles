# macOS-specific environment variables
# Sourced from .zshenv for early availability

export STUDIO_JDK=${JAVA_HOME%/*/*}
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export JAVA_OPTS="-Djava.net.useSystemProxies=true"
export CATALINA_HOME=/opt/homebrew/Cellar/tomcat/10.1.19/libexec/
export ANT_OPTS=-Dbuild.sysclasspath=ignore
export HOMEBREW_BUNDLE_FILE_GLOBAL="$XDG_CONFIG_HOME/Brewfile"

# vim: set syntax=zsh:
