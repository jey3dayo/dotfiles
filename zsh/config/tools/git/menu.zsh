# Git menu system and action functions
# Dependencies: core.zsh, widgets.zsh (_git_diff, _git_status, _git_switch_branch, _git_browse, git_add_interactive)

# Git menu widget (fzf)
git_menu_widget() {
  _git_widget _git_menu
}

_git_menu() {
  command -v fzf >/dev/null 2>&1 || return 0

  local options=()
  options+=("🔄 Sync")
  options+=("📄 Status")
  options+=("🧾 Diff")
  options+=("➕ Add (patch)")
  if command -v fzf-git-stashes-widget >/dev/null 2>&1; then
    options+=("📦 Stash Picker")
  fi
  options+=("🔀 Switch Branch")
  options+=("🔀 Switch Worktree")
  options+=("🧾 Diff (staged)")
  options+=("↩️ Restore (patch)")
  options+=("✅ Commit")
  options+=("⬆️ Push")
  options+=("🚧 Stash Push")
  options+=("🔀 Rebase Continue/Abort")
  options+=("📜 Log (graph)")
  options+=("➕ New Worktree")
  options+=("📋 List Worktrees")
  options+=("🌐 Browse (gh)")
  options+=("🧹 Remove Branch")
  options+=("🗑️ Remove Worktree")

  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Git Action: " --height="${ZSH_GIT_FZF_HEIGHT}" --reverse)

  if [[ -n "$choice" ]]; then
    case "$choice" in
      "🔄 Sync")
        _git_sync_action
        ;;
      "📄 Status")
        _git_status
        ;;
      "🧾 Diff")
        _git_diff_menu_action
        ;;
      "➕ Add (patch)")
        git_add_interactive
        ;;
      "📦 Stash Picker")
        fzf-git-stashes-widget
        ;;
      "🔀 Switch Branch")
        _git_switch_branch
        ;;
      "🔀 Switch Worktree")
        _git_worktree_switch_action
        ;;
      "🧾 Diff (staged)")
        _git_diff_staged_action
        ;;
      "↩️ Restore (patch)")
        _git_restore_patch_action
        ;;
      "✅ Commit")
        _git_commit_action
        ;;
      "⬆️ Push")
        _git_push_action
        ;;
      "🚧 Stash Push")
        _git_stash_push_action
        ;;
      "🔀 Rebase Continue/Abort")
        _git_rebase_action
        ;;
      "📜 Log (graph)")
        _git_log_graph_action
        ;;
      "➕ New Worktree")
        _git_worktree_new_action
        ;;
      "📋 List Worktrees")
        _git_worktree_list_action
        ;;
      "🧹 Remove Branch")
        _git_worktree_remove_branch_action
        ;;
      "🌐 Browse (gh)")
        _git_browse
        ;;
      "🗑️ Remove Worktree")
        _git_worktree_remove_action
        ;;
    esac
  fi
}

_register_git_widget git_menu_widget '^gg' '^g^g'

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

_git_diff_staged_action() {
  echo "git diff --cached"
  git diff --cached
}

_git_restore_patch_action() {
  if (( ${+widgets[accept-line]} )); then
    BUFFER="git restore -p"
    zle accept-line
  else
    echo "git restore -p"
    git restore -p
  fi
}

_git_commit_action() {
  if git diff --cached --quiet --ignore-submodules --; then
    echo "No staged changes. Stage files first (e.g., git add -p)."
    return 1
  fi

  echo "git commit"
  git commit
}

_git_push_action() {
  local current_branch
  current_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
  if [[ -z "$current_branch" ]]; then
    echo "Not on a branch (detached HEAD). Checkout a branch first."
    return 1
  fi

  if git rev-parse --abbrev-ref --symbolic-full-name "@{upstream}" >/dev/null 2>&1; then
    echo "git push"
    git push
    return $?
  fi

  local remote
  remote="origin"
  if ! git remote get-url "$remote" >/dev/null 2>&1; then
    remote=$(git remote | awk 'NR==1{print $1}')
  fi

  if [[ -z "$remote" ]]; then
    echo "No git remote found. Add remote first."
    return 1
  fi

  echo "git push -u $remote $current_branch"
  git push -u "$remote" "$current_branch"
}

_git_stash_push_action() {
  local stash_message
  stash_message=$(printf '\n' | fzf --print-query --prompt="Stash message (empty=default): " --height=5 --reverse | awk 'NR==1 { print }')

  if [[ -n "$stash_message" ]]; then
    echo "git stash push -m \"$stash_message\""
    git stash push -m "$stash_message"
  else
    echo "git stash push"
    git stash push
  fi
}

_git_rebase_in_progress() {
  local git_dir
  git_dir=$(git rev-parse --git-dir 2>/dev/null) || return 1
  [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]
}

_git_rebase_action() {
  local options=()
  options+=("Continue")
  options+=("Abort")
  options+=("Skip")
  options+=("Status")

  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Rebase Action: " --height=8 --reverse)
  if [[ -z "$choice" ]]; then
    return 0
  fi

  case "$choice" in
    "Status")
      echo "git status -sb"
      git status -sb
      ;;
    "Continue")
      if ! _git_rebase_in_progress; then
        echo "No rebase in progress."
        return 1
      fi
      echo "git rebase --continue"
      git rebase --continue
      ;;
    "Abort")
      if ! _git_rebase_in_progress; then
        echo "No rebase in progress."
        return 1
      fi
      echo "git rebase --abort"
      git rebase --abort
      ;;
    "Skip")
      if ! _git_rebase_in_progress; then
        echo "No rebase in progress."
        return 1
      fi
      echo "git rebase --skip"
      git rebase --skip
      ;;
  esac
}

_git_log_graph_action() {
  echo "git log --oneline --graph --decorate --all -n 50"
  git log --oneline --graph --decorate --all -n 50
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

# vim: set syntax=zsh:
