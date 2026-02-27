# Git worktree management, wt wrapper, and completions
# Dependencies: core.zsh (_is_git_repo, _git_widget, _register_git_widget, _git_wt_list, _git_wt_require, _git_branch_list)

# Worktree actions (shared by menus)
_git_worktree_switch_action() {
  _git_wt_require || return 1

  local worktree
  worktree=$(_git_wt_list | fzf --prompt="Switch to worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

  if [[ -n "$worktree" ]]; then
    local wt_path
    wt_path=$(command git wt --nocd "$worktree" 2>&1 | tail -1)
    if [[ -d "$wt_path" ]]; then
      BUFFER="cd $wt_path"
      zle accept-line
    fi
  fi
}

_git_worktree_new_action() {
  _git_wt_require || return 1

  local branch_name
  branch_name=$(echo "" | fzf --print-query --prompt="Enter branch name for new worktree: " --height=5 | head -1)
  if [[ -n "$branch_name" ]]; then
    echo "Creating worktree for branch: $branch_name"
    local wt_path
    wt_path=$(command git wt --nocd "$branch_name" 2>&1 | tail -1)
    if [[ -d "$wt_path" ]]; then
      echo "cd $wt_path"
      cd "$wt_path"
    fi
  fi
}

_git_worktree_list_action() {
  _git_wt_require || return 1
  echo "git wt"
  git wt
}

_git_worktree_remove_action() {
  _git_wt_require || return 1

  local worktrees
  worktrees=(${(f)"$(_git_wt_list | fzf --multi --prompt="Remove worktree (Tab to select multiple): " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{if ($1=="*") print $2; else print $1}')"})

  if [[ ${#worktrees[@]} -gt 0 ]]; then
    echo "Selected worktrees to remove:"
    printf '  - %s\n' "${worktrees[@]}"
    echo ""

    echo -n "Delete branches too? [y/N]: "
    read -r confirm

    local delete_branches=false
    case "$confirm" in
      [yY]*)
        delete_branches=true
        ;;
    esac

    for worktree in "${worktrees[@]}"; do
      if $delete_branches; then
        echo "git wt -d $worktree"
        git wt -d "$worktree"
      else
        echo "git worktree remove $worktree"
        git worktree remove "$worktree"
      fi
    done
  fi
}

_git_worktree_remove_branch_action() {
  local branches
  branches=(${(f)"$(_git_branch_list | fzf --multi --prompt="Remove branch (Tab to select multiple): " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse --preview="git log --oneline --graph --color=always --max-count=20 {}")"})

  if [[ ${#branches[@]} -gt 0 ]]; then
    echo "Selected branches to remove:"
    printf '  - %s\n' "${branches[@]}"
    echo ""

    echo -n "Force delete (including unmerged)? [y/N]: "
    read -r confirm

    local force_delete=false
    case "$confirm" in
      [yY]*)
        force_delete=true
        ;;
    esac

    for branch in "${branches[@]}"; do
      if $force_delete; then
        echo "git branch -D $branch"
        git branch -D "$branch"
      else
        echo "git branch -d $branch"
        git branch -d "$branch"
      fi
    done
  fi
}

# Git worktree management widget (using git-wt)
git_worktree_widget() {
  _git_widget _git_worktree_menu
}

_git_worktree_menu() {
  command -v fzf >/dev/null 2>&1 || return 0
  _git_wt_require || return 1

  # Build menu options (git-wt powered)
  local options=()
  options+=("🔀 Switch Worktree")
  options+=("➕ New Worktree")
  options+=("📋 List Worktrees")
  options+=("🗑️ Remove Worktree")
  options+=("🧹 Remove Branch")

  # Show menu
  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Worktree Action: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse)

  if [[ -n "$choice" ]]; then
    case "$choice" in
      "🔀 Switch Worktree")
        _git_worktree_switch_action
        ;;
      "➕ New Worktree")
        _git_worktree_new_action
        ;;
      "📋 List Worktrees")
        _git_worktree_list_action
        ;;
      "🗑️ Remove Worktree")
        _git_worktree_remove_action
        ;;
      "🧹 Remove Branch")
        _git_worktree_remove_branch_action
        ;;
    esac
  fi
}

# Git worktree open widget (direct worktree selection without menu)
git_worktree_open_widget() {
  _git_widget _git_worktree_open
}

_git_worktree_open() {
  command -v fzf >/dev/null 2>&1 || return 0
  command -v git-wt >/dev/null 2>&1 || {
    echo "git-wt not installed. Install with: mise install"
    return 1
  }

  local worktree
  worktree=$(_git_wt_list | fzf --prompt="Open worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

  if [[ -n "$worktree" ]]; then
    local wt_path
    wt_path=$(command git wt --nocd "$worktree" 2>&1 | tail -1)
    if [[ -d "$wt_path" ]]; then
      BUFFER="cd $wt_path"
      zle accept-line
    fi
  fi
}

_register_git_widget git_worktree_widget '^g^W' '^gW'
_register_git_widget git_worktree_open_widget '^gw' '^g^w'

# Interactive git-wt wrapper with fzf filtering
wt() {
  if ! _is_git_repo; then
    echo "wt: not in a git worktree"
    return 1
  fi

  if ! command -v git-wt >/dev/null 2>&1; then
    echo "git-wt not installed. Install with: mise install"
    return 1
  fi

  if [[ $# -eq 0 ]]; then
    # No arguments: interactive fzf selection
    local worktree
    worktree=$(_git_wt_list | fzf --prompt="Select worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

    if [[ -n "$worktree" ]]; then
      local wt_path
      wt_path=$(command git wt --nocd "$worktree" 2>&1 | tail -1)
      if [[ -d "$wt_path" ]]; then
        cd "$wt_path"
      fi
    fi
  else
    # Arguments provided: pass through to git wt and cd to result
    local wt_path
    wt_path=$(command git wt --nocd "$@" 2>&1 | tail -1)
    if [[ -d "$wt_path" ]]; then
      cd "$wt_path"
    fi
  fi
}

# Zsh completion for wt wrapper
_wt() {
  emulate -L zsh
  _is_git_repo || return 1

  if command -v git-wt >/dev/null 2>&1; then
    local -a wt_branches
    wt_branches=(${(f)"$(_git_wt_list | awk '{print $(NF-1)}')"})
    compadd -a wt_branches
  fi
}

compdef _wt wt

# fzf-git compatibility: avoid tmux popup flags that older tmux can't handle.
if typeset -f _fzf_git_fzf >/dev/null 2>&1; then
  _fzf_git_fzf() {
    fzf --height 50% \
      --layout reverse --multi --min-height 20+ --border \
      --no-separator --header-border horizontal \
      --border-label-pos 2 \
      --color 'label:blue' \
      --preview-window 'right,50%' --preview-border line \
      --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' "$@"
  }
fi

# vim: set syntax=zsh:
