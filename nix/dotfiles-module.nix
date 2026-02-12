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

    is_dotfiles_repo() {
      local candidate="$1"

      if ! ${pkgs.git}/bin/git -C "$candidate" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 1
      fi

      local root
      root="$(${pkgs.git}/bin/git -C "$candidate" rev-parse --show-toplevel 2>/dev/null)" || return 1

      if [ -f "$root/flake.nix" ] && [ -f "$root/home.nix" ] && [ -f "$root/nix/dotfiles-module.nix" ]; then
        worktree="$root"
        return 0
      fi

      return 1
    }

    if [ -n "$repo_worktree" ] && is_dotfiles_repo "$repo_worktree"; then
      :
    elif [ -n "''${DOTFILES_WORKTREE:-}" ] && is_dotfiles_repo "''${DOTFILES_WORKTREE}"; then
      :
    elif is_dotfiles_repo "$repo_path"; then
      :
    else
      # Use bash array for safe iteration with spaces in paths
      candidates=(
${worktreeCandidateLines}
      )
      for candidate in "''${candidates[@]}"; do
        if is_dotfiles_repo "$candidate"; then
          break
        fi
      done
    fi
  '';

  # gitignore.nix を使った真のgitignore-aware filter
  cleanedRepo = gitignore.lib.gitignoreSource cfg.repoPath;

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

      # SSH config (with proper permissions)
      (lib.mkIf cfg.deploySsh (mkHomeFiles sshFiles))

      # Bash files
      (lib.mkIf cfg.deployBash (mkHomeFiles bashFiles))

      # AWSume config
      (lib.mkIf cfg.deployAwsume (mkHomeFiles awsumeFiles))
    ];

    # NOTE: ~/.config is managed directly by git checkout, not by Nix/Home Manager.
    # The following activation scripts may still be needed if you have runtime state
    # that needs initialization (e.g., projects-config, mise trusted-configs, tmux plugins).

    # Git submodule initialization (activation script)
    home.activation.dotfiles-submodules = lib.mkIf cfg.initSubmodules (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Initialize Git submodules for tmux plugins
        ${detectWorktreeScript}

        if [ -n "$worktree" ]; then
          echo "Initializing Git submodules for tmux plugins..."
          if ! ${pkgs.git}/bin/git -C "$worktree" submodule update --init --recursive; then
            echo "Warning: failed to initialize tmux plugin submodules; continuing activation." >&2
          fi
        fi
      ''
    );
  };
}
