function peco-src () {
    local selected_dir=$(ghq list --full-path | peco --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-src
bindkey '^T' peco-src

function peco-src-open () {
    local selected_dir=$(ghq list | peco --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        BUFFER="open https:\/\/${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-src-open
bindkey '^Y' peco-src-open
