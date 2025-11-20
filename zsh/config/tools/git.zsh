# Git configuration and custom functions

# Helper function to check if in git repository
_is_git_repo() {
  [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = 'true' ]
}

# Git diff widget function
git_diff() {
  if _is_git_repo; then
    echo git diff
    git diff
  fi
  zle reset-prompt
}
zle -N git_diff git_diff
bindkey '^gg' git_diff
bindkey '^g^g' git_diff

# Git status widget function
git_status() {
  if _is_git_repo; then
    echo git status
    git status -sb
  fi
  zle reset-prompt
}
zle -N git_status git_status
bindkey '^g^s' git_status

# Git switch widget (local branch switching with fzf)
git_switch_widget() {
  if _is_git_repo && command -v fzf >/dev/null 2>&1; then
    local branch
    # Show only local branches (excluding remote branches)
    branch=$(git branch --format='%(refname:short)' | fzf --prompt="Switch to branch: " --height=40% --reverse --preview="git log --oneline --graph --color=always {}")
    if [[ -n "$branch" ]]; then
      echo "git switch $branch"
      git switch "$branch"
    fi
  fi
  zle reset-prompt
}
zle -N git_switch_widget git_switch_widget
bindkey '^gs' git_switch_widget

# Git add widget function
git_add_interactive() {
  if _is_git_repo; then
    echo git add -p
    git add -p
  fi
  zle reset-prompt
}
zle -N git_add_interactive git_add_interactive
bindkey '^ga' git_add_interactive
bindkey '^g^a' git_add_interactive

# Git worktree management widget (using fzf if available)
git_worktree_widget() {
  if _is_git_repo && command -v fzf >/dev/null 2>&1; then
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
  fi
  zle reset-prompt
}
zle -N git_worktree_widget git_worktree_widget
bindkey '^gw' git_worktree_widget
bindkey '^g^w' git_worktree_widget
