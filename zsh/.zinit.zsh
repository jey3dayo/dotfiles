source "${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

## Added by Zinit's installer
if [[ ! -f $HOME/.config/zsh/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.config/zsh/.zinit" && command chmod g-rwX "$HOME/.config/zsh/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.config/zsh/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node \
    atinit"zicompinit; zicdreplay" \
      zdharma/fast-syntax-highlighting

zinit wait lucid light-mode for \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    PZTM::fasd \
    blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zinit is-snippet for \
  OMZL::git.zsh \
  OMZP::git

zinit wait lucid is-snippet as"completion" for \
  OMZP::docker/_docker \
  OMZP::docker-compose/_docker-compose

zinit light mollifier/anyframe
bindkey '^R' anyframe-widget-execute-history
bindkey '^T' anyframe-widget-cd-ghq-repository

