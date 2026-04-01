# Home Manager module: programs.dotfiles
# Manages dotfiles distribution using home.file and home.activation
{ gitignore }:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dotfiles;
  envDetect = import ./env-detect.nix { inherit pkgs lib; };
  files = import ./dotfiles-files.nix;

  # Detect environment or use user override
  environment = if cfg.environment != null then cfg.environment else envDetect.detectEnvironment pkgs;

  defaultWorktreeCandidates = [
    "${config.home.homeDirectory}/.config"
    "${config.home.homeDirectory}/src/github.com/${config.home.username}/dotfiles"
    "${config.home.homeDirectory}/src/dotfiles"
    "${config.home.homeDirectory}/dotfiles"
  ];

  worktreeCandidates =
    if cfg.repoWorktreeCandidates != [ ] then cfg.repoWorktreeCandidates else defaultWorktreeCandidates;

  # Generate candidate array in bash-safe way (one per line, properly quoted)
  worktreeCandidateLines = lib.concatMapStringsSep "\n" (
    path: "  ${lib.escapeShellArg path}"
  ) worktreeCandidates;

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

  inherit (files)
    entryPointFiles
    materializedEntryPointFiles
    bashFiles
    sshFiles
    awsumeFiles
    ;

  mkHomeFiles =
    fileset:
    lib.mapAttrs (_: relativePath: {
      source = "${cleanedRepo}/${relativePath}";
    }) fileset;

  mkMaterializedFilesScript =
    fileset:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        targetPath: relativePath:
        let
          sourcePath = "${cleanedRepo}/${relativePath}";
          targetPathAbs = "${config.home.homeDirectory}/${targetPath}";
        in
        ''
          target=${lib.escapeShellArg targetPathAbs}
          source=${lib.escapeShellArg sourcePath}
          target_dir="$(${pkgs.coreutils}/bin/dirname "$target")"

          if [ -d "$target" ] && [ ! -L "$target" ]; then
            echo "Refusing to replace directory: $target" >&2
            exit 1
          fi

          run ${pkgs.coreutils}/bin/mkdir -p "$target_dir"

          if [ -L "$target" ] || [ ! -f "$target" ] || ! ${pkgs.coreutils}/bin/cmp -s "$source" "$target"; then
            verboseEcho "Materializing $target"
            if [ -e "$target" ] || [ -L "$target" ]; then
              run ${pkgs.coreutils}/bin/rm -f "$target"
            fi
            run ${pkgs.coreutils}/bin/install -m 600 "$source" "$target"
          fi
        ''
      ) fileset
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
      default = [ ];
      description = ''
        Candidate worktree paths to search when repoWorktreePath is null.
        Absolute paths are recommended. If empty, defaults to common locations under $HOME.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "ci"
          "pi"
          "default"
        ]
      );
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
    home = {
      # Set MISE_CONFIG_FILE environment variable based on detected environment
      sessionVariables = {
        MISE_CONFIG_FILE = "${config.xdg.configHome}/mise/config.${environment}.toml";
      };

      # Deploy configuration files
      file = lib.mkMerge [
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
      activation.dotfiles-submodules = lib.mkIf cfg.initSubmodules (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Initialize tpm submodule and auto-install tmux plugins
          ${detectWorktreeScript}

          if [ -n "$worktree" ]; then
            echo "Initializing Git submodules for tpm..."
            if ! ${pkgs.git}/bin/git -C "$worktree" submodule update --init --recursive; then
              echo "Warning: failed to initialize tpm submodule; continuing activation." >&2
            fi

            # Auto-install TPM plugins if tmux server is not running
            tpm_path="$worktree/tmux/plugins/tpm"
            install_script="$tpm_path/bin/install_plugins"
            if [ -x "$install_script" ] && ! ${pkgs.tmux}/bin/tmux info &>/dev/null; then
              echo "Installing tmux plugins via TPM..."
              PATH="${pkgs.tmux}/bin:/usr/bin:/bin:$PATH" TMUX_PLUGIN_MANAGER_PATH="$worktree/tmux/plugins" "$install_script" || \
                echo "Warning: TPM plugin install failed; run <prefix>I inside tmux." >&2
            fi
          fi
        ''
      );

      activation.dotfiles-materialized-entrypoints = lib.mkIf cfg.deployEntryPoints (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          # Materialize configs for CLIs that reject Home Manager symlinks.
          ${mkMaterializedFilesScript materializedEntryPointFiles}
        ''
      );
    };
  };
}
