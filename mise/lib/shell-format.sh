#!/usr/bin/env sh
# shellcheck disable=SC2086  # Intentional word splitting: space-separated arg lists (SH_FILES, TASK_EXCLUDES, etc.)
# mise/lib/shell-format.sh
# Shell formatter/checker for .sh and .zsh files.
#
# Usage:
#   CHECK=0 sh ./mise/lib/shell-format.sh   # write mode (format:shell)
#   CHECK=1 sh ./mise/lib/shell-format.sh   # check mode (format:shell:check)
#
# Environment:
#   CHECK         - 0: write, 1: check (default: 0)
#   SH_FILES      - space-separated list of files to process (optional)
#   TASK_EXCLUDES - fd exclude flags (set by mise env)

CHECK="${CHECK:-0}"

if [ -n "${SH_FILES:-}" ]; then
  zsh_files=""
  shfmt_files=""
  for file in ${SH_FILES}; do
    case "$file" in
      *.zsh)
        zsh_files="${zsh_files} ${file}"
        ;;
      *)
        shfmt_files="${shfmt_files} ${file}"
        ;;
    esac
  done

  if [ -n "${shfmt_files}" ]; then
    if [ "$CHECK" = "1" ]; then
      shfmt -d -i 2 -ci -bn ${shfmt_files}
    else
      shfmt -w -i 2 -ci -bn ${shfmt_files}
    fi
  fi

  if [ -n "${zsh_files}" ]; then
    if [ "$CHECK" = "1" ]; then
      beautysh -i 2 -c ${zsh_files}
    else
      beautysh -i 2 ${zsh_files}
    fi
  fi
else
  # scripts/ (some files have no extension)
  if [ "$CHECK" = "1" ]; then
    fd -t f -H -p '^scripts/' -X shfmt -d -i 2 -ci -bn
  else
    fd -t f -H -p '^scripts/' -X shfmt -w -i 2 -ci -bn
  fi

  # .sh files elsewhere
  if [ "$CHECK" = "1" ]; then
    fd -e sh ${TASK_EXCLUDES} -X shfmt -d -i 2 -ci -bn
  else
    fd -e sh ${TASK_EXCLUDES} -X shfmt -w -i 2 -ci -bn
  fi

  # .zsh files
  if [ "$CHECK" = "1" ]; then
    fd -e zsh ${TASK_EXCLUDES} -X beautysh -i 2 -c
    fd -t f -H -p '^zsh/bin/' -X beautysh -i 2 -c
  else
    fd -e zsh ${TASK_EXCLUDES} -X beautysh -i 2
    fd -t f -H -p '^zsh/bin/' -X beautysh -i 2
  fi
fi
