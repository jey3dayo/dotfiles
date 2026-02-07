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
    "mise"
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
    "projects-config"
    "yamllint"
  ];

  # XDG config files (dotfiles in ~/.config/)
  xdgConfigFiles = [
    ".agignore"
    ".aicommits"
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
  ];

  # Entry point files to deploy to home directory
  entryPointFiles = {
    ".gitconfig" = "home/.gitconfig";
    ".tmux.conf" = "home/.tmux.conf";
    ".zshenv" = "home/.zshenv";
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
    ];

    # Git submodule initialization (activation script)
    home.activation.dotfiles-submodules = lib.mkIf cfg.initSubmodules (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # Initialize Git submodules for tmux plugins
        if [ -d "${cfg.repoPath}/.git" ]; then
          echo "Initializing Git submodules for tmux plugins..."
          cd "${cfg.repoPath}"
          ${pkgs.git}/bin/git submodule update --init --recursive
        fi
      ''
    );
  };
}
