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
  local status=$?
  zle reset-prompt
  return $status
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

_register_git_widget git_status '^g^s'

# Git switch widget (local branch switching with fzf)
_git_switch_branch() {
  command -v fzf >/dev/null 2>&1 || return 0

  local branch
  # Show only local branches (excluding remote branches)
  branch=$(git branch --format='%(refname:short)' | fzf --prompt="Switch to branch: " --height=40% --reverse --preview="git log --oneline --graph --color=always {}")
  if [[ -n "$branch" ]]; then
    echo "git switch $branch"
    git switch "$branch"
  fi
}

git_switch_widget() {
  _git_widget _git_switch_branch
}

_register_git_widget git_switch_widget '^gs' '^g^b'

# Git add widget function
_git_add_patch() {
  echo git add -p
  git add -p
}

git_add_interactive() {
  _git_widget _git_add_patch
}

_register_git_widget git_add_interactive '^ga' '^g^a'

# Git worktree management widget (using fzf if available)
git_worktree_widget() {
  _git_widget _git_worktree_menu
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
        # Parse git worktree list and select worktree
        local worktree_info
        worktree_info=$(git worktree list --porcelain | awk '
          /^worktree / { path = substr($0, 10); }
          /^branch / {
            branch = $2;
            sub("^refs/heads/", "", branch);
            print branch "\t" path;
            path = ""; branch = ""
          }
        ' | fzf --prompt="Select worktree: " --height=40% --reverse --delimiter='\t' --with-nth=1)

        if [[ -n "$worktree_info" ]]; then
          local worktree_path=$(echo "$worktree_info" | cut -f2)
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
        # Select and remove worktree
        local worktree_info
        worktree_info=$(git worktree list --porcelain | awk '
          /^worktree / {
            path = substr($0, 10);
            getline;
            if ($0 !~ /^branch/) { next; }
          }
          /^branch / {
            branch = $2;
            sub("^refs/heads/", "", branch);
            print branch "\t" path;
            path = ""; branch = ""
          }
        ' | grep -v "$(git rev-parse --show-toplevel)" | fzf --prompt="Remove worktree: " --height=40% --reverse --delimiter='\t' --with-nth=1)

        if [[ -n "$worktree_info" ]]; then
          local worktree_path=$(echo "$worktree_info" | cut -f2)
          echo "git worktree remove $worktree_path"
          git worktree remove "$worktree_path"
        fi
        ;;
    esac
  fi
}

_register_git_widget git_worktree_widget '^gw' '^g^w'

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
