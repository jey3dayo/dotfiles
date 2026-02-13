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
  local -a keymaps=(emacs viins vicmd)
  local keymap key

  zle -N "$widget" "$widget"
  for key in "$@"; do
    for keymap in "${keymaps[@]}"; do
      bindkey -M "$keymap" "$key" "$widget"
    done
  done
}

# git-wt list helper (skip header if present)
_git_wt_list() {
  command git wt | awk 'NR==1 && $1=="PATH" && $2=="BRANCH" {next} {print}'
}

_git_wt_require() {
  command -v git-wt >/dev/null 2>&1 || {
    echo "git-wt not installed. Install with: mise install"
    return 1
  }
}

# Local branch list helper (excluding current branch if possible)
_git_branch_list() {
  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  if [[ -n "$current_branch" ]]; then
    git for-each-ref refs/heads --format='%(refname:short)' | grep -Fxv "$current_branch"
  else
    git for-each-ref refs/heads --format='%(refname:short)'
  fi
}

# Git diff widget function
_git_diff() {
  echo git diff
  git diff
}

git_diff() {
  _git_widget _git_diff
}

# Git menu widget (fzf)
git_menu_widget() {
  _git_widget _git_menu
}

_git_menu() {
  command -v fzf >/dev/null 2>&1 || return 0

  local options=()
  options+=("🧾 Diff")
  options+=("📄 Status")
  options+=("🔀 Switch Branch")
  options+=("🔄 Sync")
  options+=("➕ Add (patch)")
  options+=("🔀 Switch Worktree")
  options+=("➕ New Worktree")
  options+=("📋 List Worktrees")
  options+=("🗑️ Remove Worktree")
  options+=("🧹 Remove Branch")
  if command -v fzf-git-stashes-widget >/dev/null 2>&1; then
    options+=("📦 Stash Picker")
  fi
  options+=("🌐 Browse (gh)")

  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Git Action: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse)

  if [[ -n "$choice" ]]; then
    case "$choice" in
      "📄 Status")
        _git_status
        ;;
      "🧾 Diff")
        _git_diff_menu_action
        ;;
      "🔄 Sync")
        _git_sync_action
        ;;
      "➕ Add (patch)")
        git_add_interactive
        ;;
      "🔀 Switch Branch")
        _git_switch_branch
        ;;
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
      "📦 Stash Picker")
        fzf-git-stashes-widget
        ;;
      "🌐 Browse (gh)")
        _git_browse
        ;;
    esac
  fi
}

_register_git_widget git_menu_widget '^gg' '^g^g'

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

_git_diff_menu_action() {
  local options=()
  options+=("Working tree (git diff)")
  options+=("HEAD^1")
  options+=("origin/develop")
  options+=("origin/main")
  options+=("Name-only vs origin/develop")
  options+=("Name-only vs origin/main")

  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Diff: " --height=10 --reverse)
  if [[ -z "$choice" ]]; then
    return 0
  fi

  case "$choice" in
    "Working tree (git diff)")
      _git_diff
      ;;
    "HEAD^1")
      echo "git diff HEAD^1"
      git diff HEAD^1
      ;;
    "origin/develop")
      echo "git diff origin/develop"
      git diff origin/develop
      ;;
    "origin/main")
      echo "git diff origin/main"
      git diff origin/main
      ;;
    "Name-only vs origin/develop")
      echo "git diff --name-only origin/develop"
      git diff --name-only origin/develop
      ;;
    "Name-only vs origin/main")
      echo "git diff --name-only origin/main"
      git diff --name-only origin/main
      ;;
  esac
}

_git_sync_action() {
  local options=()
  options+=("Update base (main/develop)")
  options+=("Update current (ff-only)")
  options+=("Rebase current onto base (main/develop)")
  options+=("Fetch (prune)")

  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Sync Action: " --height=10 --reverse)

  if [[ -n "$choice" ]]; then
    case "$choice" in
      "Update base (main/develop)")
        _git_sync_update_base_action
        ;;
      "Update current (ff-only)")
        echo "git pull --ff-only"
        git pull --ff-only
        ;;
      "Rebase current onto base (main/develop)")
        _git_sync_rebase_action
        ;;
      "Fetch (prune)")
        echo "git fetch origin --prune"
        git fetch origin --prune
        ;;
    esac
  fi
}

_git_sync_update_base_action() {
  local base
  local current_branch

  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  base=$(printf '%s\n' "develop" "main" | fzf --prompt="Update base: " --height=6 --reverse)
  if [[ -z "$base" ]]; then
    return 0
  fi

  if [[ -n "$current_branch" && "$current_branch" != "$base" ]]; then
    echo "git switch $base"
    git switch "$base" || return 1
    echo "git pull --ff-only"
    git pull --ff-only
    echo "git switch $current_branch"
    git switch "$current_branch"
  else
    echo "git pull --ff-only"
    git pull --ff-only
  fi
}

_git_sync_rebase_action() {
  local base
  base=$(printf '%s\n' "develop" "main" | fzf --prompt="Rebase onto base: " --height=6 --reverse)
  if [[ -z "$base" ]]; then
    return 0
  fi

  echo "git fetch origin --prune"
  git fetch origin --prune
  echo "git rebase origin/$base"
  git rebase "origin/$base"
}

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
