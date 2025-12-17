# Git configuration and custom functions

# Helper function to check if in git repository
_is_git_repo() {
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = 'true' ]
}

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

# Worktree path resolver for a branch
_git_worktree_for_branch() {
  local branch="$1"
  git worktree list --porcelain | awk -v target="$branch" '
    $1=="worktree" { path=$2 }
    $1=="branch" {
      br=$2
      sub("^refs/heads/", "", br)
      if (br == target) { print path; exit }
      path=""
    }
  '
}

# Branch selector (prefers fzf-git)
_git_select_branch() {
  if command -v _fzf_git_branches >/dev/null 2>&1; then
    _fzf_git_branches | head -n1
  else
    git branch --format='%(refname:short)' | fzf --prompt="Switch to branch: " --height=40% --reverse --preview="git log --oneline --graph --color=always {}"
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

  local worktree_path
  worktree_path=$(_git_worktree_for_branch "$branch")
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

# Git worktree management widget (using fzf if available)
git_worktree_widget() {
  _git_widget _git_worktree_menu
}

_git_select_worktree() {
  if command -v _fzf_git_worktrees >/dev/null 2>&1; then
    _fzf_git_worktrees | head -n1
  else
    git worktree list --porcelain | awk '/^worktree / { print $2 }' | fzf --prompt="Select worktree: " --height=40% --reverse
  fi
}

_git_worktree_menu() {
  command -v fzf >/dev/null 2>&1 || return 0

  # Build menu options
  local options=()
  options+=("🔀 Open Worktree")
  options+=("➕ New Worktree")
  options+=("📋 List Worktrees")
  options+=("🗑️  Remove Worktree")

  # Show menu
  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Worktree Action: " --height=40% --reverse)

  if [[ -n "$choice" ]]; then
    case "$choice" in
      "🔀 Open Worktree")
        local worktree_path
        worktree_path=$(_git_select_worktree)

        if [[ -n "$worktree_path" ]]; then
          if [[ -d "$worktree_path" ]]; then
            echo "cd $worktree_path"
            cd "$worktree_path"
          else
            echo "Warning: Worktree path does not exist: $worktree_path"
            echo "Consider running: git worktree prune"
          fi
        fi
        ;;
      "➕ New Worktree")
        # Create new worktree - use vared for better zle integration
        local branch_name=""
        vared -p "Enter branch name for new worktree: " branch_name
        if [[ -n "$branch_name" ]]; then
          # Get the parent directory of current repo
          local repo_root=$(git rev-parse --show-toplevel)
          local parent_dir=$(dirname "$repo_root")
          local worktree_path="$parent_dir/$branch_name"

          echo "git worktree add $worktree_path -b $branch_name"
          git worktree add "$worktree_path" -b "$branch_name"

          # If successful, cd to new worktree
          if [[ $? -eq 0 ]] && [[ -d "$worktree_path" ]]; then
            cd "$worktree_path"
          fi
        fi
        ;;
      "📋 List Worktrees")
        # Show worktree list
        echo "git worktree list"
        git worktree list
        ;;
      "🗑️  Remove Worktree")
        local worktree_path
        worktree_path=$(_git_select_worktree)

        if [[ -n "$worktree_path" ]]; then
          local current_root
          current_root=$(git rev-parse --show-toplevel)
          if [[ "$worktree_path" == "$current_root" ]]; then
            echo "Cannot remove current worktree: $worktree_path"
            return 1
          fi

          echo "git worktree remove $worktree_path"
          git worktree remove "$worktree_path"
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

  local worktree_path
  worktree_path=$(_git_select_worktree)

  if [[ -n "$worktree_path" ]]; then
    if [[ -d "$worktree_path" ]]; then
      echo "cd $worktree_path"
      cd "$worktree_path"
    else
      echo "Warning: Worktree path does not exist: $worktree_path"
      echo "Consider running: git worktree prune"
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

# Worktree quick cd by branch name
wtcd() {
  local branch="$1"
  if [[ -z "$branch" ]]; then
    echo "usage: wtcd <branch>"
    return 1
  fi

  if ! _is_git_repo; then
    echo "wtcd: not in a git worktree"
    return 1
  fi

  local wt_path
  wt_path=$(git worktree list --porcelain | awk -v b="$branch" '
    $1=="worktree" { p=$2 }
    $1=="branch" {
      br=$2
      sub("^refs/heads/", "", br)
      if (br == b) { print p; exit }
    }
  ')

  if [[ -z "$wt_path" ]]; then
    echo "no worktree for $branch"
    return 1
  fi

  if [[ ! -d "$wt_path" ]]; then
    echo "worktree path missing: $wt_path"
    echo "consider: git worktree prune"
    return 1
  fi

  cd "$wt_path"
}

# Dedicated completion (decoupled from git's _git to avoid __git_find_on_cmdline errors)
_wtcd() {
  emulate -L zsh
  _is_git_repo || return 1
  local -a wt_branches
  wt_branches=(${(f)"$(git worktree list --porcelain | awk '
    $1=="branch" {
      br=$2
      sub("^refs/heads/", "", br)
      print br
    }
  ')"})
  compadd -a wt_branches
}

# Completion setup that overwrites any _git fallback
_wtcd_register_completion() {
  (( $+functions[compdef] )) || return 1
  compdef -d wtcd 2>/dev/null
  compdef _wtcd wtcd
}

# Apply now; if compinit isn't ready, queue a hook for later
if ! _wtcd_register_completion 2>/dev/null; then
  typeset -g -a _post_compinit_hooks
  _post_compinit_hooks+=("_wtcd_register_completion")
fi

autoload -Uz add-zsh-hook 2>/dev/null
(( $+functions[add-zsh-hook] )) && add-zsh-hook -Uz precmd _wtcd_register_completion
