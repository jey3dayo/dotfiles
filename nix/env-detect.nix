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

      # Raspberry Pi detection helper.
      # NOTE:
      # - `/proc/cpuinfo` is a pseudo filesystem file (size 0), so `builtins.readFile`
      #   returns an empty string during Nix evaluation — it cannot be used for detection.
      # - `/sys/firmware/devicetree/base/model` contains NUL bytes, so `builtins.readFile`
      #   would fail, but `builtins.pathExists` works reliably. However, this file exists
      #   on many ARM Linux systems (Jetson, Odroid, etc.), not just Raspberry Pi.
      # - `/boot/firmware/config.txt` is Raspberry Pi-specific boot configuration.
      # - We require BOTH markers (AND condition) to avoid false positives on non-Pi ARM SBCs.
      isRaspberryPiModel =
        let
          hasDeviceTree = builtins.pathExists "/sys/firmware/devicetree/base/model";
          hasPiBootConfig = builtins.pathExists "/boot/firmware/config.txt";
        in
        pkgs.stdenv.isLinux && hasDeviceTree && hasPiBootConfig;

      # CI detection: $CI or $GITHUB_ACTIONS environment variables
      isCI = hasEnvValue "CI" "true" || hasEnvValue "GITHUB_ACTIONS" "true";

      # Explicit environment override via $DOTFILES_ENVIRONMENT
      # Allows manual control: DOTFILES_ENVIRONMENT=pi home-manager switch ...
      envOverride = builtins.getEnv "DOTFILES_ENVIRONMENT";
      hasEnvOverride = envOverride == "ci" || envOverride == "pi" || envOverride == "default";

      # Raspberry Pi detection: ARM Linux + Raspberry Pi specific file markers
      isRaspberryPi =
        (pkgs.stdenv.hostPlatform.isAarch64 || pkgs.stdenv.hostPlatform.isAarch32) &&
        isRaspberryPiModel;

    in
    # Priority: Explicit override > CI > Pi > Default
    if hasEnvOverride then envOverride
    else if isCI then "ci"
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
