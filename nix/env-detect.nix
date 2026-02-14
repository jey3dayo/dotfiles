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
      # - `/sys/firmware/devicetree/base/model` (and `/proc/device-tree/model`) often contain NUL bytes,
      #   which `builtins.readFile` cannot represent as a Nix string.
      # - `/proc/cpuinfo` is safe text on Linux, but doesn't exist on e.g. Darwin.
      # - On Raspberry Pi 4/5, model name can be missing in some fields, so check BCM SoC IDs as fallback.
      isRaspberryPiModel =
        let
          cpuinfoPath = "/proc/cpuinfo";
          cpuinfoRead = builtins.tryEval (builtins.readFile cpuinfoPath);
          cpuinfo = if cpuinfoRead.success then cpuinfoRead.value else "";
          hasRaspberryPiString = builtins.match ".*Raspberry Pi.*" cpuinfo != null;
          hasBcm27xxString = builtins.match ".*BCM27[0-9][0-9].*" cpuinfo != null;
          hasBcm283xString = builtins.match ".*BCM283[0-9].*" cpuinfo != null;
        in
        pkgs.stdenv.isLinux && cpuinfoRead.success &&
        (hasRaspberryPiString || hasBcm27xxString || hasBcm283xString);

      # CI detection: $CI or $GITHUB_ACTIONS environment variables
      isCI = hasEnvValue "CI" "true" || hasEnvValue "GITHUB_ACTIONS" "true";

      # Raspberry Pi detection: ARM Linux + Raspberry Pi specific cpuinfo markers
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
