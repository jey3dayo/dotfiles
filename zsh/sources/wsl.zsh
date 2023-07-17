[[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || return

export DIRENV_BIN="$HOME/.config/zsh/.zinit/polaris/bin/direnv"
eval "$($DIRENV_BIN hook zsh)"

export ASDF_DIR=$HOME/.asdf
. $ASDF_DIR/asdf.sh

fpath=(${ASDF_DIR}/completions $fpath)

# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit
