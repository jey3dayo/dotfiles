# j138 .zshrc

export LANG=ja_JP.UTF-8
#export LANG=ja_JP.eucJP
#export LANG=ja_JP.shift-jis

export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$HOME/bin:$HOME/sbin
export MANPATH=/opt/local/man:$MANPATH

if [ -f "$HOME/.zshrc.mine" ]; then
	source "$HOME/.zshrc.mine"
fi

# setopt
setopt always_last_prompt
setopt append_history
setopt auto_cd
setopt auto_menu
setopt auto_name_dirs
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt auto_remove_slash
setopt complete_aliases
setopt complete_in_word
setopt correct
setopt extended_glob
setopt extended_history
setopt globdots
setopt hist_ignore_dups
setopt hist_ignore_space
setopt list_packed
setopt hist_verify
setopt list_types
setopt magic_equal_subst
setopt mark_dirs
setopt no_beep
setopt noautoremoveslash
setopt nolistbeep
setopt noautoremoveslash
setopt nonomatch
setopt notify
setopt print_eight_bit
setopt prompt_subst
setopt pushd_ignore_dups
setopt rm_star_silent
setopt rm_star_wait
setopt share_history

autoload zed
bindkey -e
bindkey "^[[3~" delete-char

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

# Command history configuration
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

# ignorecase 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1

export LISTMAX=0
export GREP_OPTIONS='--color=auto'

# Completion configuration
fpath=(~/.zsh/functions/Completion ${fpath})
autoload -U compinit
compinit -u

## Prediction configuration
#autoload predict-on
#predict-on

# alias
alias where="command -v"
alias datef="date +%F"
alias df="df -h"
alias du="du -h"
alias diff="colordiff"
alias less="less -R"
alias l='ls -lAFhp'
alias ls='ls -pF'
alias su="su -l"
alias hg="hg --encoding=utf-8"
alias gst="git status -s"
alias gad="git add"

# set prompt {{{
autoload colors
colors
case ${UID} in
    0)
    PROMPT="%B%{${fg[red]}%}%/#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
    PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
    *)
    PROMPT="%{${fg[red]}%}%/%%%{${reset_color}%} "
    PROMPT2="%{${fg[red]}%}%_%%%{${reset_color}%} "
    SPROMPT="%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%} "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
    PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
esac
# }}}

# terminal configuration {{{
unset LSCOLORS
case "${TERM}" in
    xterm)
    export TERM=xterm-color
    ;;
    kterm)
    export TERM=kterm-color
    # set BackSpace control character
    stty erase
    ;;
    cons25)
    unset LANG
    export LSCOLORS=ExFxCxdxBxegedabagacad
    export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors \
    'di=;34;1' 'ln=;35;1' 'so=;32;1' 'ex=31;1' 'bd=46;34' 'cd=43;34'
    ;;
esac
# }}}

# set terminal title including current directory {{{
case "${TERM}" in
    kterm*|xterm*)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD}\007"
    }
    export LSCOLORS=exfxcxdxbxegedabagacad
    export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
    zstyle ':completion:*' list-colors \
    'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'
    ;;
esac
# }}}

## show branch name {{{
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
precmd () {
	psvar=()
	LANG=en_US.UTF-8 vcs_info
	[[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
RPROMPT="%1(v|%F{green}%1v%f|)"
# }}}

# git complete
__git_files() { _files }

# mosh complete
compdef mosh=ssh
# rvm path
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# z command
export _Z_DATA=~/tmp/.z
