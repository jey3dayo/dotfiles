do_enter() {
    if [[ -n $BUFFER ]]; then
        zle accept-line
        return $status
    fi

    echo
    if [[ -d .git ]]; then
        if [[ -n "$(git status --short)" ]]; then
            git status -sb
        fi
    else
      :
    fi

    zle reset-prompt
}
zle -N do_enter
bindkey '^m' do_enter
