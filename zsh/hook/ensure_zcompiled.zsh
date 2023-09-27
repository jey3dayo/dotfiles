# source command override technique
function source {
  ensure_zcompiled $1
  builtin source $1
}

function ensure_zcompiled {
  if [[ "$1" == *.zsh ]] || [[ "$1" == *.zshrc ]]; then
    local compiled="$1.zwc"
    if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
      echo "\033[1;36mCompiling\033[m $1"
      zcompile $1
    fi
  else
    # echo "reject $1"
  fi
}
