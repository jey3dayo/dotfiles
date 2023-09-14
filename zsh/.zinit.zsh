source "${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

## Added by Zinit's installer
if [[ ! -f $HOME/.config/zsh/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.config/zsh/.zinit" && command chmod g-rwX "$HOME/.config/zsh/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.config/zsh/.zinit/bin" && \

        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

zinit light-mode for \
    romkatv/powerlevel10k \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-bin-gem-node \
    PZTM::fasd \
    atinit"zicompinit; zicdreplay" \
      zdharma/fast-syntax-highlighting

zinit wait lucid light-mode for \
    olets/zsh-abbr \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit is-snippet for \
  OMZL::git.zsh \
  OMZP::git

zinit load azu/ni.zsh

zinit light mollifier/anyframe
bindkey '^gh' anyframe-widget-execute-history
bindkey '^gi' anyframe-widget-put-history
bindkey '^gr' anyframe-widget-cd-ghq-repository
bindkey '^gb' anyframe-widget-checkout-git-branch
bindkey '^gk' anyframe-widget-kill

bindkey '^R' anyframe-widget-execute-history
bindkey '^T' anyframe-widget-cd-ghq-repository
bindkey '^Y' anyframe-widget-checkout-git-branch
