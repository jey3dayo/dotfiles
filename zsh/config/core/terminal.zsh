# Terminal state management
# Fixes apps (e.g. Claude Code) that enable Kitty Keyboard Protocol but don't restore it on C-z

_reset_keyboard_protocol() {
  printf '\x1b[=0;1u'
}
precmd_functions+=(_reset_keyboard_protocol)

# vim: set syntax=zsh:
