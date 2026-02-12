# Environment detection for dotfiles configuration
# Determines environment type: ci, pi, or default (includes WSL2, macOS, generic Linux)
{ pkgs, lib }:

{
  # Detect environment based on system properties and environment variables
  # Returns: "ci" | "pi" | "default"
  # Note: WSL2, macOS, and generic Linux all use "default" configuration
  detectEnvironment = pkgs:
    let
      # Helper functions
      hasEnv = name: builtins.getEnv name != "";
      hasEnvValue = name: value: builtins.getEnv name == value;

      # File content checker (returns false if file doesn't exist)
      # Note: /sys/firmware/devicetree/base/model contains NUL bytes, so builtins.readFile
      # cannot represent it as a Nix string. Use a text source without NULs instead.
      fileContains = path: pattern:
        let
          fileExists = builtins.pathExists path;
          content = if fileExists then builtins.readFile path else "";
        in
        fileExists && builtins.match ".*${pattern}.*" content != null;

      # Raspberry Pi detection helper.
      # NOTE:
      # - `/sys/firmware/devicetree/base/model` (and `/proc/device-tree/model`) often contain NUL bytes,
      #   which `builtins.readFile` cannot represent as a Nix string.
      # - `/proc/cpuinfo` is safe text on Linux, but doesn't exist on e.g. Darwin.
      isRaspberryPiModel =
        pkgs.stdenv.isLinux && builtins.pathExists "/proc/cpuinfo" &&
        builtins.match ".*Raspberry Pi.*" (builtins.readFile "/proc/cpuinfo") != null;

      # CI detection: $CI or $GITHUB_ACTIONS environment variables
      isCI = hasEnvValue "CI" "true" || hasEnvValue "GITHUB_ACTIONS" "true";

      # Raspberry Pi detection: ARM architecture + model string contains "Raspberry Pi"
      isRaspberryPi =
        (pkgs.stdenv.hostPlatform.isAarch64 || pkgs.stdenv.hostPlatform.isAarch32) &&
        isRaspberryPiModel;

    in
    # Priority: CI > Pi > Default (includes WSL2, macOS, generic Linux)
    if isCI then "ci"
    else if isRaspberryPi then "pi"
    else "default";

  # Get mise config file path for the detected environment
  # Args: config - home-manager config object
  # Returns: path to mise config file
  getMiseConfigPath = config: pkgs:
    let
      self = import ./env-detect.nix { inherit pkgs lib; };
      environment = self.detectEnvironment pkgs;
      configHome = config.xdg.configHome;
    in
    "${configHome}/mise/config.${environment}.toml";
}
