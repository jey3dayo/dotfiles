#!/bin/sh
set -e

if command -v powershell.exe >/dev/null 2>&1; then
  powershell_exe=$(command -v powershell.exe)
elif [ -x /mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe ]; then
  powershell_exe=/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe
elif [ -x /c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe ]; then
  powershell_exe=/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
else
  echo "powershell.exe not found" >&2
  exit 127
fi

exec "$powershell_exe" -NoProfile -ExecutionPolicy Bypass -File "$@"
