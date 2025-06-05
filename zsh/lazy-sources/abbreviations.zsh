# Abbreviations setup
# zsh-abbrプラグインが読み込まれた後に実行される

abbrコマンドが利用可能かチェック
if ! (( $+commands[abbr] )) && ! (( $+functions[abbr] )); then
  return
fi

abbr -f -S less="less -giMRSW -z-4 -x4"
abbr -f -S where="command -v"
abbr -f -S df="df -h"
abbr -f -S du="du -h"
abbr -f -S tailf="tail -f"
abbr -f -S pk='pkill -9 -f '

abbr -f -S cat='bat'
abbr -f -S top='btop'
abbr -f -S l='eza -la'
abbr -f -S ll='eza -la'
abbr -f -S ls='eza'
abbr -f -S la='eza -la'

# tricks
abbr -f -S path='echo -e ${PATH//:/\\n}'
abbr -f -S myip="ip -br -c a"
abbr -f -S ports="lsof -i -P -n | grep LISTEN"
abbr -f -S wifi="networksetup -setairportpower en0"  # wifi on/off

# git
abbr -f -S ga="git add"
abbr -f -S gap="git add -p"
abbr -f -S gst="git status -sb ."
abbr -f -S gc="git commit -m\ ""
abbr -f -S gd="git diff"
abbr -f -S gdc="git diff --cached"
abbr -f -S gd1="git diff HEAD~1"
abbr -f -S gd2="git diff HEAD~2"
abbr -f -S gd3="git diff HEAD~3"
abbr -f -S gb="git branch"
abbr -f -S gco="git checkout"
abbr -f -S gcob="git checkout -b"
abbr -f -S gl="git log --oneline -10"
abbr -f -S gp="git push"
abbr -f -S gpl="git pull"

# dev
abbr -f -S vim="nvim"
abbr -f -S vi="nvim"
abbr -f -S ag="rg --hidden"
abbr -f -S rg="rg --hidden"
abbr -f -S d='docker'
abbr -f -S dc='docker compose'
abbr -f -S nx="nlx"
abbr -f -S hg="hg --encoding=utf-8"
abbr -f -S typos="typos --config ~/.config/typos.toml ."

# Mac
abbr -f -S chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
abbr -f -S flusdns="dscacheutil -flushcache;sudo killall -HUP mDNSResponder"

# vim: set syntax=zsh:
