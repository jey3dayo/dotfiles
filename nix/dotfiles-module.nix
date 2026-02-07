# Home Manager module: programs.dotfiles
# Manages dotfiles distribution using home.file and home.activation
{ gitignore }:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dotfiles;
  envDetect = import ./env-detect.nix { inherit pkgs lib; };

  # Detect environment or use user override
  environment =
    if cfg.environment != null then
      cfg.environment
    else
      envDetect.detectEnvironment pkgs;

  # gitignore.nix を使った真のgitignore-aware filter
  cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;

  # XDG directories to deploy to ~/.config/ (静的なもののみ)
  xdgConfigDirs = [
    # Core tools (already managed)
    "git"
    # mise: excluded - writable trust DB required (managed individually below)
    "nvim"
    "tmux"
    "zsh"

    # Terminal emulators
    "alacritty"
    "wezterm"

    # Shell enhancements
    "zsh-abbr"

    # Editors and IDEs
    "cursor"
    "ghostty"

    # Development tools
    "helm"
    "efm-langserver"
    "needle"
    "opencode"

    # System monitoring
    "btop"
    "htop"

    # Misc tools
    "flipper"
    "scripts"
    "yamllint"
  ];

  # XDG config files (dotfiles in ~/.config/)
  xdgConfigFiles = [
    ".agignore"
    ".asdfrc"
    ".busted"
    ".clang-format"
    ".colordiffrc"
    ".ctags"
    ".cvimrc"
    ".editorconfig"
    ".env"                # dotenvx暗号化済み
    ".fdignore"
    ".gvimrc"
    ".ignore"
    ".luacheckrc"
    ".luarc.json"
    ".markdown-link-check.json"
    ".markdownlint-cli2.jsonc"
    ".marksman.toml"
    ".mise.toml"
    ".prettierignore"
    ".rainbarf.conf"
    ".ripgreprc"
    ".rubocop.yml"
    ".screenrc"
    ".styluaignore"
    ".surfingkeys.js"
    ".vimperatorrc"
    "Brewfile"
    "typos.toml"
  ];

  # Entry point files to deploy to home directory
  entryPointFiles = {
    ".aicommits" = ".aicommits";
    ".gitconfig" = "home/.gitconfig";
    ".tmux.conf" = "home/.tmux.conf";
    ".zshenv" = "home/.zshenv";
    ".zshrc" = "home/.zshrc";
  };

  # Bash files to deploy
  bashFiles = {
    ".bashrc" = "bash/.bashrc";
    ".bash_profile" = "bash/.bash_profile";
  };

in
{
  options.programs.dotfiles = {
    enable = lib.mkEnableOption "Dotfiles configuration management with Home Manager";

    repoPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to dotfiles repository root.";
    };

    repoWorktreePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Path to the dotfiles working tree on disk (used for git submodule init).
        Use this when repoPath points to the Nix store (e.g. repoPath = ./.).
      '';
    };

    environment = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "ci" "pi" "default" ]);
      default = null;
      description = ''
        Environment type for configuration selection.
        null = auto-detect (CI > Pi > Default), or specify: "ci", "pi", "default".
        Note: WSL2, macOS, and generic Linux all use "default" configuration.
      '';
    };

    deployEntryPoints = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy entry point files (~/.gitconfig, ~/.zshenv, ~/.tmux.conf).";
    };

    deployXdgConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy XDG config directories (~/.config/{zsh,nvim,git,tmux,mise}).";
    };

    deploySsh = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy SSH configuration (~/.ssh/config).";
    };

    deployBash = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy Bash configuration (~/.bashrc, ~/.bash_profile).";
    };

    deployAwsume = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy AWSume configuration (~/.awsume/config.yaml).";
    };

    initSubmodules = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Initialize Git submodules (tmux plugins).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Set MISE_CONFIG_FILE environment variable based on detected environment
    home.sessionVariables = {
      MISE_CONFIG_FILE = "${config.xdg.configHome}/mise/config.${environment}.toml";
    };

    # Deploy configuration files
    home.file = lib.mkMerge [
      # Entry point files (home directory)
      (lib.mkIf cfg.deployEntryPoints (
        lib.mapAttrs
          (name: relativePath: {
            source = "${cleanedRepo}/${relativePath}";
          })
          entryPointFiles
      ))

      # XDG config directories (symlink entire directory)
      (lib.mkIf cfg.deployXdgConfig (
        lib.listToAttrs (
          map
            (dir: {
              name = ".config/${dir}";
              value = {
                source = "${cleanedRepo}/${dir}";
              };
            })
            xdgConfigDirs
        )
      ))

      # XDG config files (individual files in ~/.config/)
      (lib.mkIf cfg.deployXdgConfig (
        lib.listToAttrs (
          map
            (file: {
              name = ".config/${file}";
              value = {
                source = "${cleanedRepo}/${file}";
              };
            })
            xdgConfigFiles
        )
      ))

      # SSH config (with proper permissions)
      (lib.mkIf cfg.deploySsh {
        ".ssh/config" = {
          source = "${cleanedRepo}/ssh/config";
        };
      })

      # Bash files
      (lib.mkIf cfg.deployBash (
        lib.mapAttrs
          (name: relativePath: {
            source = "${cleanedRepo}/${relativePath}";
          })
          bashFiles
      ))

      # AWSume config
      (lib.mkIf cfg.deployAwsume {
        ".awsume/config.yaml" = {
          source = "${cleanedRepo}/awsume/config.yaml";
        };
      })

      # mise static configs (dynamic files like trusted-configs/ need writable directory)
      (lib.mkIf cfg.deployXdgConfig {
        ".config/mise/config.toml" = {
          source = "${cleanedRepo}/mise/config.toml";
        };
        ".config/mise/config.default.toml" = {
          source = "${cleanedRepo}/mise/config.default.toml";
        };
        ".config/mise/config.pi.toml" = {
          source = "${cleanedRepo}/mise/config.pi.toml";
        };
        ".config/mise/config.ci.toml" = {
          source = "${cleanedRepo}/mise/config.ci.toml";
        };
        ".config/mise/README.md" = {
          source = "${cleanedRepo}/mise/README.md";
        };
      })
    ];

    # Ensure writable directories (not Nix store symlinks) for runtime state
    home.activation.dotfiles-writable-dirs = lib.mkIf cfg.deployXdgConfig (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # projects-config: nvim-projectconfig writes project settings
        projects_dir="${config.xdg.configHome}/projects-config"
        if [ -L "$projects_dir" ]; then
          rm -f "$projects_dir"
        fi
        if [ -e "$projects_dir" ] && [ ! -d "$projects_dir" ]; then
          echo "Warning: $projects_dir exists and is not a directory; skipping creation." >&2
        else
          mkdir -p "$projects_dir"
        fi

        # mise: trusted-configs/ and other runtime state need write access
        mise_dir="${config.xdg.configHome}/mise"
        mise_tasks_dir="$mise_dir/tasks"

        # Create mise directory if it doesn't exist or is a symlink
        if [ -L "$mise_dir" ]; then
          echo "Warning: $mise_dir is a symlink; removing to create real directory" >&2
          rm -f "$mise_dir"
        fi
        mkdir -p "$mise_dir" "$mise_tasks_dir"

        # Copy tasks directory content if source exists
        if [ -d "${cleanedRepo}/mise/tasks" ]; then
          cp -r "${cleanedRepo}/mise/tasks"/. "$mise_tasks_dir/" 2>/dev/null || true
        fi
      ''
    );

    # Git submodule initialization (activation script)
    home.activation.dotfiles-submodules = lib.mkIf cfg.initSubmodules (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Initialize Git submodules for tmux plugins
        repo_path="${cfg.repoPath}"
        repo_worktree="${lib.optionalString (cfg.repoWorktreePath != null) cfg.repoWorktreePath}"
        worktree=""

        if [ -n "$repo_worktree" ] && ${pkgs.git}/bin/git -C "$repo_worktree" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          worktree="$repo_worktree"
        elif [ -n "''${DOTFILES_WORKTREE:-}" ] && ${pkgs.git}/bin/git -C "''${DOTFILES_WORKTREE}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          worktree="''${DOTFILES_WORKTREE}"
        elif ${pkgs.git}/bin/git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          worktree="$repo_path"
        else
          for candidate in \
            "${config.home.homeDirectory}/src/github.com/jey3dayo/dotfiles" \
            "${config.home.homeDirectory}/src/dotfiles" \
            "${config.home.homeDirectory}/dotfiles"; do
            if ${pkgs.git}/bin/git -C "$candidate" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              worktree="$candidate"
              break
            fi
          done
        fi

        if [ -n "$worktree" ]; then
          echo "Initializing Git submodules for tmux plugins..."
          ${pkgs.git}/bin/git -C "$worktree" submodule update --init --recursive
        fi
      ''
    );
  };
}
