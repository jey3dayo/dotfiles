[[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]] || return

export ASDF_DIR=$HOME/.asdf
. $ASDF_DIR/asdf.sh

fpath=(${ASDF_DIR}/completions $fpath)
