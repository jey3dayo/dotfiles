if command -v sw_vers > /dev/null 2>&1 && command -v arch > /dev/null 2>&1; then
  alias x64='exec arch -x86_64 /bin/zsh'
  alias a64='exec arch -arm64e /bin/zsh'
  switch-arch() {
    if [[ "$(arch)" == arm64 ]]; then
      arch=x86_64
    elif [[ "$(arch)" == i386 ]]; then
      arch=arm64e
    fi
    print "switched $arch"
    exec arch -"${arch}" /bin/zsh
  }
fi
