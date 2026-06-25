# Home Manager configuration for dotfiles
{
  lib,
  pkgs,
  username,
  homeDirectory,
  ...
}:

let
  guiPath = builtins.concatStringsSep ":" [
    "${homeDirectory}/.mise/shims"
    "${homeDirectory}/bin"
    "${homeDirectory}/.local/bin"
    "${homeDirectory}/.config/scripts"
    "${homeDirectory}/.cargo/bin"
    "${homeDirectory}/go/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/usr/local/bin"
    "/usr/local/sbin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
in
{
  # Basic home-manager settings
  home = {
    inherit username homeDirectory;

    # Fundamental packages (if needed)
    packages = with pkgs; [
      rsync # Required for copy-tree deployment
      btop
    ];

    # This value determines the Home Manager release that your configuration is compatible with.
    # You should not change this value, even if you update Home Manager.
    stateVersion = "24.11";

    activation.headroom-logs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.coreutils}/bin/mkdir -p "${homeDirectory}/.headroom/logs"
    '';
  };

  # Tools are installed via mise; Home Manager focuses on config distribution.

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    # Enable dotfiles module
    dotfiles = {
      enable = true;
      repoPath = ../..; # dotfiles repository root
      repoWorktreePath = null; # Auto-detect from repoPath or fallback paths
      environment = null; # Auto-detect (override with "ci"/"pi"/"default")

      # Deployment options (Phase 2: enable file deployment)
      # NOTE: ~/.config is managed directly by git checkout, not by Nix/Home Manager
      deployEntryPoints = true; # Deploy ~/.gitconfig, ~/.zshenv, etc.
      deploySsh = true; # Deploy ~/.ssh/config
      deployBash = true; # Deploy ~/.bashrc, ~/.bash_profile
      deployAwsume = true; # Deploy ~/.awsume/config.yaml
      deployMacosServices = true; # Deploy ~/Library/Services/*.workflow (Darwin only)
      initSubmodules = true; # Initialize Git submodules (tmux plugins)
    };

  };

  launchd.agents.codex-gui-path = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-lc"
        "launchctl setenv PATH '${guiPath}'"
      ];
      RunAtLoad = true;
      StandardOutPath = "${homeDirectory}/Library/Logs/codex-gui-path.log";
      StandardErrorPath = "${homeDirectory}/Library/Logs/codex-gui-path.log";
    };
  };

  launchd.agents.headroom-proxy = {
    enable = pkgs.stdenv.hostPlatform.isDarwin;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-lc"
        ''
          ${pkgs.coreutils}/bin/mkdir -p "${homeDirectory}/.headroom/logs"
          export XDG_CONFIG_HOME="${homeDirectory}/.config"
          export MISE_DATA_DIR="${homeDirectory}/.mise"
          export MISE_CACHE_DIR="${homeDirectory}/.cache/mise"
          export MISE_CONFIG_FILE="${homeDirectory}/.config/mise/config.default.toml"
          export PATH='${guiPath}'
          headroom_bin="$("${homeDirectory}/.local/bin/mise" which headroom)"
          exec "$headroom_bin" proxy \
            --host 127.0.0.1 \
            --port 8787 \
            --mode cache \
            --no-learn \
            --no-memory-tools \
            --no-telemetry \
            --log-file "${homeDirectory}/.headroom/logs/proxy.jsonl"
        ''
      ];
      EnvironmentVariables = {
        XDG_CONFIG_HOME = "${homeDirectory}/.config";
        MISE_DATA_DIR = "${homeDirectory}/.mise";
        MISE_CACHE_DIR = "${homeDirectory}/.cache/mise";
        MISE_CONFIG_FILE = "${homeDirectory}/.config/mise/config.default.toml";
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = "${homeDirectory}/.headroom/logs/proxy.stdout.log";
      StandardErrorPath = "${homeDirectory}/.headroom/logs/proxy.stderr.log";
    };
  };
}
