[[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || return 0

if [[ "$PWD" == /mnt/c/Users/* || "$PWD" == /c/Users/* ]]; then
  cd "$HOME" || return
fi

path=("${path[@]}" /mnt/c/Windows/System32 /mnt/c/Windows)

alias explorer='explorer.exe'
alias clip='clip.exe'
alias wsl='wsl.exe'
alias open='explorer.exe .'

export BROWSER='/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'

# vim: set syntax=zsh:
