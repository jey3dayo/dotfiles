# Help functions for zsh configuration

zsh-help() {
  case "$1" in
  keybinds | keys)
    echo "🔗 Custom Keybindings:"
    echo "  ^]       - fzf ghq repository selector"
    echo "  ^[       - git branch/worktree navigator"
    echo "  ^g^g     - git diff widget"
    echo "  ^g^s     - git status widget"
    echo "  ^g^a     - git add interactive widget"
    echo "  ^g^b     - git branch/worktree widget"
    echo "  ^g^K     - fzf kill process widget"
    echo "  ^R       - fzf history search"
    echo "  ^T       - fzf file finder"
    echo ""
    echo "Alternative key combinations:"
    echo "  ^gg, ^gs, ^ga, ^gb - Single ^g variants"
    ;;
  aliases | abbr)
    echo "📝 Command Abbreviations:"
    if command -v abbr >/dev/null 2>&1; then
      echo ""
      echo "Git commands:"
      abbr -S | grep -E "^abbr.*g[a-z]=" | sort
      echo ""
      echo "System commands:"
      abbr -S | grep -E "^abbr.*(ls|cat|vim|top|df|du)=" | sort
      echo ""
      echo "Development tools:"
      abbr -S | grep -E "^abbr.*(docker|nx|rg|ag)=" | sort
      echo ""
      echo "Other abbreviations:"
      abbr -S | grep -vE "^abbr.*(g[a-z]=|ls|cat|vim|top|df|du|docker|nx|rg|ag)=" | sort
    else
      echo "zsh-abbr plugin not loaded"
    fi
    ;;
  functions | funcs)
    echo "⚙️  Custom Functions:"
    echo ""
    echo "Git functions:"
    typeset -f | grep -E "^git_[a-zA-Z_-]+\s*\(\)" | sed 's/() {//' | sort
    echo ""
    echo "FZF functions:"
    typeset -f | grep -E "^fzf_[a-zA-Z_-]+\s*\(\)" | sed 's/() {//' | sort
    echo ""
    echo "Helper functions:"
    typeset -f | grep -E "^_[a-zA-Z_-]+\s*\(\)" | sed 's/() {//' | sort
    echo ""
    echo "Other functions:"
    typeset -f | grep -E "^[a-zA-Z][a-zA-Z_-]*\s*\(\)" | grep -vE "^(git_|fzf_|_)" | sed 's/() {//' | sort
    ;;
  config | structure)
    echo "📁 Configuration Structure:"
    echo "  config/core/     - Core settings (immediate load)"
    echo "    ├── aliases.zsh   - Basic command aliases"
    echo "    ├── brew.zsh      - Homebrew configuration"
    echo "    └── path.zsh      - PATH environment setup"
    echo ""
    echo "  config/tools/    - Tool-specific settings (deferred)"
    echo "    ├── fzf.zsh       - FZF configuration"
    echo "    ├── git.zsh       - Git widgets and functions"
    echo "    ├── mise.zsh      - Version manager setup"
    echo "    └── starship.zsh  - Prompt configuration"
    echo ""
    echo "  config/os/       - OS-specific settings"
    echo "    └── macos.zsh     - macOS specific configurations"
    echo ""
    echo "  functions/       - Custom functions"
    echo "  lazy-sources/    - Deferred loading scripts"
    echo "  sheldon/         - Plugin management"
    ;;
  tools | plugins)
    echo "🔧 Available Tools & Plugins:"
    echo ""
    echo "Package managers:"
    command -v brew >/dev/null && echo "  ✅ Homebrew"
    command -v mise >/dev/null && echo "  ✅ mise (version manager)"
    echo ""
    echo "Development tools:"
    command -v fzf >/dev/null && echo "  ✅ fzf (fuzzy finder)"
    command -v rg >/dev/null && echo "  ✅ ripgrep"
    command -v bat >/dev/null && echo "  ✅ bat (better cat)"
    command -v eza >/dev/null && echo "  ✅ eza (better ls)"
    command -v btop >/dev/null && echo "  ✅ btop (better top)"
    echo ""
    echo "Shell enhancements:"
    command -v starship >/dev/null && echo "  ✅ Starship prompt"
    command -v abbr >/dev/null && echo "  ✅ zsh-abbr"
    command -v sheldon >/dev/null && echo "  ✅ Sheldon plugin manager"
    ;;
  benchmark | perf)
    echo "⏱️  Performance Tools:"
    echo ""
    echo "To benchmark shell startup time:"
    echo "  time (zsh -i -c exit)"
    echo ""
    echo "To enable zsh profiling:"
    echo "  export ZSH_DEBUG=1"
    echo "  exec zsh"
    echo "  zprof | head -20"
    ;;
  *)
    echo "🚀 Zsh Configuration Help"
    echo ""
    echo "Usage: zsh-help [topic]"
    echo ""
    echo "Available topics:"
    echo "  keybinds   - Show custom key bindings"
    echo "  aliases    - Show command abbreviations"
    echo "  functions  - Show custom functions"
    echo "  config     - Show configuration structure"
    echo "  tools      - Show available tools & plugins"
    echo "  benchmark  - Show performance tools"
    echo ""
    echo "Shortcuts: keys, abbr, funcs, structure, plugins, perf"
    ;;
  esac
}
