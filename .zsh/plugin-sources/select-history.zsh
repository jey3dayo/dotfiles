OPTIONS='--select-1'

function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        awk '!a[$0]++'  | \
        peco "$OPTIONS" --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^R' peco-select-history
