# peco
if command -v peco>/dev/null; then
  alias s='ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config|grep -v \*|peco|awk "{print \$2}")'
fi
