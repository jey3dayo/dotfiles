[[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || return

# WSL: Force home directory on startup if in Windows directory
if [[ "$PWD" == /mnt/c/Users/* ]] || [[ "$PWD" == /c/Users/* ]]; then
  cd "$HOME" || exit
fi

# WSL-specific PATH adjustments
# Add Windows system directories if needed
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"

# WSL utilities
alias explorer='explorer.exe'
alias clip='clip.exe'
alias wsl='wsl.exe'

# Open current directory in Windows Explorer
alias open='explorer.exe .'

# WSL-specific environment variables
export BROWSER='/mnt/c/Program Files/Google/Chrome/Application/chrome.exe'
