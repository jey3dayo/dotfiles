dotfiles_load_git_widgets() {
  emulate -L zsh
  [[ -n "${DOTFILES_GIT_WIDGETS_LOADED:-}" ]] && return 0
  command -v git >/dev/null 2>&1 || return 0
  command -v fzf >/dev/null 2>&1 || return 0

  local fzf_git="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon/repos/github.com/junegunn/fzf-git.sh/fzf-git.sh"
  [[ -r "$fzf_git" ]] || return 0

  (( $+functions[dotfiles_load_fzf] )) && dotfiles_load_fzf

  DOTFILES_GIT_WIDGETS_LOADED=1
  source "$fzf_git"
  dotfiles_register_git_widgets
}

dotfiles_git_is_repo() {
  [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]
}

dotfiles_git_switch_branch() {
  dotfiles_git_is_repo || return 1
  (( $+functions[_fzf_git_branches] )) || return 1

  local branch
  branch="$(_fzf_git_branches --no-multi)"
  [[ -n "$branch" ]] || return 0

  local worktree_path
  worktree_path="$(
    git worktree list --porcelain | awk -v target="$branch" '
      $1=="worktree" { path=$2 }
      $1=="branch" {
        br=$2
        sub("^refs/heads/", "", br)
        if (br == target) { print path; exit }
        path=""
      }
    '
  )"

  if [[ -n "$worktree_path" && -d "$worktree_path" ]]; then
    cd "$worktree_path" || return
    return 0
  fi

  if git rev-parse --verify --quiet "$branch" >/dev/null 2>&1; then
    git switch "$branch"
  else
    git switch --track --guess "$branch"
  fi
}

dotfiles_git_switch_branch_widget() {
  dotfiles_git_switch_branch
  zle reset-prompt
}

dotfiles_git_status_widget() {
  dotfiles_git_accept_command 'git status -sb'
}

dotfiles_git_add_patch_widget() {
  dotfiles_git_accept_command 'git add -p'
}

dotfiles_git_accept_command() {
  BUFFER="$1"
  zle accept-line
}

dotfiles_git_worktree_select_path() {
  git worktree list |
  fzf --prompt='Worktree> ' --height=40% --reverse \
    --preview 'git -C {1} status --short --branch 2>/dev/null' |
  awk '{print $1}'
}

dotfiles_git_worktree_widget() {
  dotfiles_git_is_repo || {
    zle reset-prompt
    return 1
  }

  local choice
  choice="$(
    printf '%s\n' \
      'open: cd to worktree' \
      'new: git worktree add' \
      'list: git worktree list' \
      'prune: git worktree prune' |
      fzf --prompt='Worktree Action: ' --height=40% --reverse
  )"

  local worktree_path
  case "$choice" in
    open:*)
      worktree_path="$(dotfiles_git_worktree_select_path)"
      [[ -n "$worktree_path" ]] || return 0
      BUFFER="cd ${(q)worktree_path}"
      zle accept-line
      ;;
    new:*)
      BUFFER='git worktree add '
      zle end-of-line
      ;;
    list:*)
      dotfiles_git_accept_command 'git worktree list'
      ;;
    prune:*)
      dotfiles_git_accept_command 'git worktree prune'
      ;;
  esac
}

dotfiles_git_menu_widget() {
  dotfiles_git_is_repo || {
    zle reset-prompt
    return 1
  }

  local choice
  choice="$(
    printf '%s\n' \
      'status: git status -sb' \
      'diff: git diff' \
      'add-patch: git add -p' \
      'switch-branch: fzf branch switch' \
      'stash-picker: fzf stash picker' \
      'git-files: fzf git file picker' \
      'worktrees: git worktree list' \
      'browse: gh browse' |
      fzf --prompt='Git Action: ' --height=40% --reverse
  )"

  case "$choice" in
    status:*)
      dotfiles_git_accept_command 'git status -sb'
      ;;
    diff:*)
      dotfiles_git_accept_command 'git diff'
      ;;
    add-patch:*)
      dotfiles_git_accept_command 'git add -p'
      ;;
    switch-branch:*)
      dotfiles_git_switch_branch
      zle reset-prompt
      ;;
    stash-picker:*)
      if (( $+widgets[fzf-git-stashes-widget] )); then
        zle fzf-git-stashes-widget
      fi
      ;;
    git-files:*)
      if (( $+widgets[fzf-git-files-widget] )); then
        zle fzf-git-files-widget
      fi
      ;;
    worktrees:*)
      dotfiles_git_accept_command 'git worktree list'
      ;;
    browse:*)
      dotfiles_git_accept_command 'gh browse'
      ;;
  esac
}

dotfiles_register_git_widgets() {
  zle -N dotfiles_git_menu_widget
  zle -N dotfiles_git_switch_branch_widget
  zle -N dotfiles_git_status_widget
  zle -N dotfiles_git_add_patch_widget
  zle -N dotfiles_git_worktree_widget

  local keymap
  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^gg' dotfiles_git_menu_widget
    bindkey -M "$keymap" '^g^g' dotfiles_git_menu_widget
    bindkey -M "$keymap" '^gs' dotfiles_git_status_widget
    bindkey -M "$keymap" '^g^s' dotfiles_git_status_widget
    bindkey -M "$keymap" '^ga' dotfiles_git_add_patch_widget
    bindkey -M "$keymap" '^g^a' dotfiles_git_add_patch_widget
    bindkey -M "$keymap" '^gb' dotfiles_git_switch_branch_widget
    bindkey -M "$keymap" '^g^b' dotfiles_git_switch_branch_widget
    bindkey -M "$keymap" '^gW' dotfiles_git_worktree_widget
    bindkey -M "$keymap" '^g^W' dotfiles_git_worktree_widget

    if (( $+widgets[fzf-git-stashes-widget] )); then
      bindkey -M "$keymap" '^gz' fzf-git-stashes-widget
      bindkey -M "$keymap" '^g^z' fzf-git-stashes-widget
    fi
  done
}

if [[ -n "${ZSH_LOAD_GIT_WIDGETS:-}" ]]; then
  dotfiles_load_git_widgets
elif [[ -o interactive ]]; then
  autoload -Uz add-zle-hook-widget

  dotfiles_load_git_widgets_once() {
    add-zle-hook-widget -d zle-line-init dotfiles_load_git_widgets_once 2>/dev/null
    dotfiles_load_git_widgets
  }

  add-zle-hook-widget zle-line-init dotfiles_load_git_widgets_once
fi

# vim: set syntax=zsh:
