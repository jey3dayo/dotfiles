# Git zle widgets and keybindings
# Dependencies: core.zsh (_is_git_repo, _git_widget, _register_git_widget, _git_select_branch)

# Git diff widget function
_git_diff() {
  echo git diff
  git diff
}

git_diff() {
  _git_widget _git_diff
}

_register_git_widget git_diff '^gd' '^g^d'

# Git status widget function
_git_status() {
  echo git status
  git status -sb
}

git_status() {
  _git_widget _git_status
}

_register_git_widget git_status '^gs' '^g^s'

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

# Expose fzf-git stash picker
if command -v fzf-git-stashes-widget >/dev/null 2>&1; then
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^gz' fzf-git-stashes-widget
    bindkey -M "$keymap" '^g^z' fzf-git-stashes-widget
  done
fi

# vim: set syntax=zsh:
