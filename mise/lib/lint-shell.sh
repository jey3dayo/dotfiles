#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2086 # SH_FILES and TASK_EXCLUDES are intentional word-split argument lists.
if [[ -n "${SH_FILES:-}" ]]; then
  zsh_files=""
  bash_files=""
  shfmt_files=""
  for file in ${SH_FILES}; do
    case "$file" in
      *.zsh | zsh/.zshenv | zsh/.zprofile | zsh/.zshrc | zsh/.zlogin | home/.zshenv | home/.zprofile | home/.zshrc | home/.zlogin | zsh/bin/*) zsh_files+=" $file" ;;
      bash/.bashrc | bash/.bash_profile) bash_files+=" $file" ;;
      *) shfmt_files+=" $file" ;;
    esac
  done

  [[ -z "$bash_files" ]] || {
    bash -n $bash_files
    shellcheck -s bash $bash_files
  }
  [[ -z "$shfmt_files" ]] || {
    shfmt -d -i 2 -ci -bn $shfmt_files
    shellcheck $shfmt_files
  }
  if [[ -n "$zsh_files" && -n "$(command -v zsh)" ]]; then
    zsh -n $zsh_files
  elif [[ -n "$zsh_files" ]]; then
    echo "⚠️ zsh not found; skipping zsh syntax check for:$zsh_files"
  fi
  exit 0
fi

fd -t f -H -p '^bin/' -X shfmt -d -i 2 -ci -bn
fd -t f -H -p '^bin/' -X shellcheck
fd -t f -H -p '^scripts/' -X shfmt -d -i 2 -ci -bn
fd -t f -H -p '^scripts/' -X shellcheck
bash -n bash/.bashrc bash/.bash_profile
shellcheck -s bash bash/.bashrc bash/.bash_profile
# shellcheck disable=SC2086 # TASK_EXCLUDES is an intentional word-split fd argument list.
fd -e sh ${TASK_EXCLUDES} -X shfmt -d -i 2 -ci -bn
# shellcheck disable=SC2086 # TASK_EXCLUDES is an intentional word-split fd argument list.
fd -e sh ${TASK_EXCLUDES} -X shellcheck

if command -v zsh >/dev/null 2>&1; then
  fd --hidden -e zsh -X zsh -n
  fd -t f -H -p '^zsh/bin/' -X zsh -n
else
  echo "⚠️ zsh not found; skipping zsh syntax checks"
fi
