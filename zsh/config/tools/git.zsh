# Git configuration and custom functions

# Helper function to check if in git repository
_is_git_repo() {
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = 'true' ]
}

# git-wt shell integration (enable automatic directory switching)
if command -v git-wt >/dev/null 2>&1; then
  eval "$(git wt --init zsh)"
fi

# Shared helpers for git widgets
_git_widget() {
  local action="$1"
  shift

  if ! _is_git_repo; then
    zle reset-prompt
    return 1
  fi

  "$action" "$@"
  local exit_status=$?
  zle reset-prompt
  return $exit_status
}

_register_git_widget() {
  local widget="$1"
  shift

  zle -N "$widget" "$widget"
  for key in "$@"; do
    bindkey "$key" "$widget"
  done
}

# Git diff widget function
_git_diff() {
  echo git diff
  git diff
}

git_diff() {
  _git_widget _git_diff
}

_register_git_widget git_diff '^gg' '^g^g'

# Git status widget function
_git_status() {
  echo git status
  git status -sb
}

git_status() {
  _git_widget _git_status
}

_register_git_widget git_status '^gs' '^g^s'

# Branch selector (prefers fzf-git)
_git_select_branch() {
  if command -v _fzf_git_branches >/dev/null 2>&1; then
    _fzf_git_branches | head -n "${ZSH_GIT_FZF_FALLBACK_LIMIT}"
  else
    git branch --format='%(refname:short)' | fzf --prompt="Switch to branch: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse --preview="git log --oneline --graph --color=always {}"
  fi
}

# Git switch widget using fzf-git for selection
_git_switch_branch() {
  command -v fzf >/dev/null 2>&1 || return 0

  local branch
  branch=$(_git_select_branch)
  if [[ -z "$branch" ]]; then
    return 0
  fi

  # Check if branch has a worktree using git worktree list
  local worktree_path
  worktree_path=$(git worktree list --porcelain | awk -v target="$branch" '
    $1=="worktree" { path=$2 }
    $1=="branch" {
      br=$2
      sub("^refs/heads/", "", br)
      if (br == target) { print path; exit }
      path=""
    }
  ')

  if [[ -n "$worktree_path" && -d "$worktree_path" ]]; then
    echo "cd $worktree_path"
    cd "$worktree_path"
    return 0
  fi

  if git rev-parse --verify --quiet "$branch" >/dev/null 2>&1; then
    echo "git switch $branch"
    git switch "$branch"
  else
    echo "git switch --track --guess $branch"
    git switch --track --guess "$branch"
  fi
}

git_switch_widget() {
  _git_widget _git_switch_branch
}

_register_git_widget git_switch_widget '^gb' '^g^b'

# Git browse widget (gh browse)
_git_browse() {
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh command not found. Please install GitHub CLI."
    return 1
  fi
  echo gh browse
  gh browse
}

git_browse_widget() {
  _git_widget _git_browse
}

_register_git_widget git_browse_widget '^go' '^g^o'

# Git add widget function
git_add_interactive() {
  if ! _is_git_repo; then
    zle reset-prompt
    return 1
  fi

  # Accept current line and run git add -p in the shell
  BUFFER="git add -p"
  zle accept-line
}

_register_git_widget git_add_interactive '^ga' '^g^a'

# Git worktree management widget (using git-wt)
git_worktree_widget() {
  _git_widget _git_worktree_menu
}

_git_worktree_menu() {
  command -v fzf >/dev/null 2>&1 || return 0
  command -v git-wt >/dev/null 2>&1 || {
    echo "git-wt not installed. Install with: mise install"
    return 1
  }

  # Build menu options (git-wt powered)
  local options=()
  options+=("🔀 Switch Worktree")
  options+=("➕ New Worktree")
  options+=("📋 List Worktrees")
  options+=("🗑️ Remove Worktree")

  # Show menu
  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Worktree Action: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse)

  if [[ -n "$choice" ]]; then
    case "$choice" in
      "🔀 Switch Worktree")
        # Use git-wt output piped through fzf
        local worktree
        worktree=$(command git wt | tail -n +2 | fzf --prompt="Switch to worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

        if [[ -n "$worktree" ]]; then
          local wt_path
          wt_path=$(command git wt --nocd "$worktree" 2>&1 | tail -1)
          if [[ -d "$wt_path" ]]; then
            BUFFER="cd $wt_path"
            zle accept-line
          fi
        fi
        ;;
      "➕ New Worktree")
        # Use fzf with print-query to get branch name input
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
        ;;
      "📋 List Worktrees")
        echo "git wt"
        git wt
        ;;
      "🗑️ Remove Worktree")
        local worktree
        worktree=$(command git wt | tail -n +2 | fzf --prompt="Remove worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

        if [[ -n "$worktree" ]]; then
          # Confirm deletion
          echo "Delete worktree: $worktree"
          echo -n "Delete branch too? [y/N]: "
          read -r confirm
          case "$confirm" in
            [yY]*)
              echo "git wt -d $worktree"
              git wt -d "$worktree"
              ;;
            *)
              echo "git wt -D $worktree (force, preserving branch if possible)"
              git wt -D "$worktree"
              ;;
          esac
        fi
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
  worktree=$(command git wt | tail -n +2 | fzf --prompt="Open worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

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

# Expose fzf-git stash picker
if command -v fzf-git-stashes-widget >/dev/null 2>&1; then
  bindkey '^gz' fzf-git-stashes-widget
  bindkey '^g^z' fzf-git-stashes-widget
fi

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
    worktree=$(command git wt | tail -n +2 | fzf --prompt="Select worktree: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse | awk '{print $(NF-1)}')

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
    wt_branches=(${(f)"$(command git wt | tail -n +2 | awk '{print $(NF-1)}')"})
    compadd -a wt_branches
  fi
}

compdef _wt wt
