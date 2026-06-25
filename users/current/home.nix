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
  headroomVersion = "0.26.0";
  headroomServiceRevision = "${headroomVersion}-service-deps-1";
  headroomPackage = "headroom-ai[mcp,proxy]==${headroomVersion}";
  headroomPinnedDeps = [
    "anyio==4.14.0"
    "click==8.4.1"
    "hpack==4.1.0"
    "litellm==1.89.3"
    "openai==2.43.0"
    "opentelemetry-api==1.42.1"
  ];
  headroomInstallArgs = lib.concatMapStringsSep " " lib.escapeShellArg (
    [ headroomPackage ] ++ headroomPinnedDeps
  );
  headroomServiceDir = "${homeDirectory}/.local/share/headroom-launchd";
  headroomVenv = "${headroomServiceDir}/venv";
  headroomBin = "${headroomVenv}/bin/headroom";
  servicePath = builtins.concatStringsSep ":" [
    "${headroomVenv}/bin"
    "${homeDirectory}/bin"
    "${homeDirectory}/.local/bin"
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

    activation.headroom-service = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.coreutils}/bin/mkdir -p "${homeDirectory}/.headroom/logs"
      ${pkgs.coreutils}/bin/mkdir -p "${headroomServiceDir}"

      marker="${headroomVenv}/.headroom-version"
      current_version=""
      if [ -f "$marker" ]; then
        current_version="$(${pkgs.coreutils}/bin/cat "$marker")"
      fi

      if [ ! -x "${headroomBin}" ] || [ "$current_version" != "${headroomServiceRevision}" ]; then
        if [ ! -x "${headroomVenv}/bin/python" ]; then
          ${pkgs.uv}/bin/uv venv --seed "${headroomVenv}"
        fi
        ${pkgs.uv}/bin/uv pip install --python "${headroomVenv}/bin/python" ${headroomInstallArgs}
        printf '%s\n' "${headroomServiceRevision}" > "$marker"
      fi
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
          if [ ! -x "${headroomBin}" ]; then
            echo "Headroom service binary is missing: ${headroomBin}" >&2
            exit 78
          fi
          export PATH='${servicePath}'
          exec "${headroomBin}" proxy \
            --host 127.0.0.1 \
            --port 8787 \
            --mode cache \
            --no-learn \
            --no-memory-tools \
            --no-telemetry \
            --log-file "${homeDirectory}/.headroom/logs/proxy.jsonl"
        ''
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      StandardOutPath = "${homeDirectory}/.headroom/logs/proxy.stdout.log";
      StandardErrorPath = "${homeDirectory}/.headroom/logs/proxy.stderr.log";
    };
  };
}
