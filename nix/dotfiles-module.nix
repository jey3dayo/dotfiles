# Home Manager module: programs.dotfiles
# Manages dotfiles distribution using home.file and home.activation
{ gitignore }:
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dotfiles;
  envDetect = import ./env-detect.nix { inherit pkgs lib; };
  files = import ./dotfiles-files.nix;

  # Detect environment or use user override
  environment =
    if cfg.environment != null then
      cfg.environment
    else
      envDetect.detectEnvironment pkgs;

  defaultWorktreeCandidates = [
    "${config.home.homeDirectory}/.config"
    "${config.home.homeDirectory}/src/github.com/${config.home.username}/dotfiles"
    "${config.home.homeDirectory}/src/dotfiles"
    "${config.home.homeDirectory}/dotfiles"
  ];

  worktreeCandidates =
    if cfg.repoWorktreeCandidates != [] then
      cfg.repoWorktreeCandidates
    else
      defaultWorktreeCandidates;

  # Generate candidate array in bash-safe way (one per line, properly quoted)
  worktreeCandidateLines = lib.concatMapStringsSep "\n" (path: "  ${lib.escapeShellArg path}") worktreeCandidates;

  detectWorktreeScript = ''
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
      # Use bash array for safe iteration with spaces in paths
      candidates=(
${worktreeCandidateLines}
      )
      for candidate in "''${candidates[@]}"; do
        if ${pkgs.git}/bin/git -C "$candidate" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          worktree="$candidate"
          break
        fi
      done
    fi
  '';

  # gitignore.nix を使った真のgitignore-aware filter
  cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;

  xdgConfigDirs = files.xdg.dirs;
  xdgConfigFiles = files.xdg.files;
  entryPointFiles = files.entryPointFiles;
  bashFiles = files.bashFiles;
  sshFiles = files.sshFiles;
  awsumeFiles = files.awsumeFiles;

  mkHomeFiles = fileset:
    lib.mapAttrs
      (_: relativePath: {
        source = "${cleanedRepo}/${relativePath}";
      })
      fileset;

  mkXdgDirs = dirs:
    lib.listToAttrs (
      map
        (dir: {
          name = ".config/${dir}";
          value = {
            source = "${cleanedRepo}/${dir}";
          };
        })
        dirs
    );

  mkXdgFiles = filesList:
    lib.listToAttrs (
      map
        (file: {
          name = ".config/${file}";
          value = {
            source = "${cleanedRepo}/${file}";
          };
        })
        filesList
    );

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

    repoWorktreeCandidates = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        Candidate worktree paths to search when repoWorktreePath is null.
        Absolute paths are recommended. If empty, defaults to common locations under $HOME.
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
      (lib.mkIf cfg.deployEntryPoints (mkHomeFiles entryPointFiles))

      # XDG config directories (symlink entire directory)
      (lib.mkIf cfg.deployXdgConfig (mkXdgDirs xdgConfigDirs))

      # XDG config files (individual files in ~/.config/)
      (lib.mkIf cfg.deployXdgConfig (mkXdgFiles xdgConfigFiles))

      # SSH config (with proper permissions)
      (lib.mkIf cfg.deploySsh (mkHomeFiles sshFiles))

      # Bash files
      (lib.mkIf cfg.deployBash (mkHomeFiles bashFiles))

      # AWSume config
      (lib.mkIf cfg.deployAwsume (mkHomeFiles awsumeFiles))
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

    # tmux configuration with submodule support
    home.activation.dotfiles-tmux-plugins = lib.mkIf cfg.deployXdgConfig (
      lib.hm.dag.entryAfter [ "writeBoundary" "dotfiles-submodules" ] ''
        tmux_config_dir="${config.xdg.configHome}/tmux"
        tmux_plugins_dir="$tmux_config_dir/plugins"

        # Create tmux directory (remove symlink if exists)
        if [ -L "$tmux_config_dir" ]; then
          echo "Warning: $tmux_config_dir is a symlink; removing to create real directory" >&2
          rm -f "$tmux_config_dir"
        fi
        mkdir -p "$tmux_config_dir" "$tmux_plugins_dir"

        # Copy static config files (symlinks will be created by home.file)
        # This ensures the directory structure exists before symlinks are created

        # Copy plugins directory structure (prefer worktree so submodules are available)
        ${detectWorktreeScript}

        plugins_source=""
        if [ -n "$worktree" ] && [ -d "$worktree/tmux/plugins" ]; then
          plugins_source="$worktree/tmux/plugins"
        elif [ -d "${cleanedRepo}/tmux/plugins" ]; then
          plugins_source="${cleanedRepo}/tmux/plugins"
        fi

        if [ -n "$plugins_source" ]; then
          cp -r "$plugins_source"/. "$tmux_plugins_dir/" 2>/dev/null || true
        fi
      ''
    );

    # Git submodule initialization (activation script)
    home.activation.dotfiles-submodules = lib.mkIf cfg.initSubmodules (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Initialize Git submodules for tmux plugins
        ${detectWorktreeScript}

        if [ -n "$worktree" ]; then
          echo "Initializing Git submodules for tmux plugins..."
          ${pkgs.git}/bin/git -C "$worktree" submodule update --init --recursive
        fi
      ''
    );
  };
}
