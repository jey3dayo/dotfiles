# Environment detection for dotfiles configuration
# Determines environment type: ci, pi, or default (includes WSL2, macOS, generic Linux)
#
# Priority: DOTFILES_ENVIRONMENT (explicit) > CI detection > Pi detection > Default
# Returns: "ci" | "pi" | "default"
#
# Edge cases (all resolve to "default"):
#   - Docker/Podman: /sys, /boot are typically not mounted, so Pi detection is safely skipped.
#   - WSL2: No WSL-specific detection; falls through to "default".
#   - Apple Silicon (macOS): isLinux=false, so Pi detection (ARM + Linux) is never triggered.
#   - ARM SBCs (Jetson, Odroid, etc.): /boot/firmware/config.txt is Raspberry Pi-specific,
#     so non-Pi ARM boards fall through to "default".
#
# Edge cases (resolve to "ci"):
#   - GitHub Codespaces: Sets CI=true, so detected as "ci".
#     If "default" behavior is desired in Codespaces, set DOTFILES_ENVIRONMENT=default.
_:

{
  # Detect environment based on system properties and environment variables
  detectEnvironment =
    pkgs:
    let
      # Helper functions
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
      # Valid values: "ci", "pi", "default"
      envOverride = builtins.getEnv "DOTFILES_ENVIRONMENT";
      isValidOverride = envOverride == "ci" || envOverride == "pi" || envOverride == "default";
      hasEnvOverride = envOverride != "" && isValidOverride;

      # Warn if DOTFILES_ENVIRONMENT is set but contains an invalid value
      _warnInvalidEnv =
        if envOverride != "" && !isValidOverride then
          builtins.trace "WARNING: DOTFILES_ENVIRONMENT='${envOverride}' is not a valid value. Valid values: ci, pi, default. Falling back to auto-detection." true
        else
          true;

      # Raspberry Pi detection: ARM Linux + Raspberry Pi specific file markers
      isRaspberryPi =
        (pkgs.stdenv.hostPlatform.isAarch64 || pkgs.stdenv.hostPlatform.isAarch32) && isRaspberryPiModel;

    in
    # Priority: Explicit override > CI > Pi > Default
    # _warnInvalidEnv is forced via `seq` to ensure the trace warning is emitted
    builtins.seq _warnInvalidEnv (
      if hasEnvOverride then
        envOverride
      else if isCI then
        "ci"
      else if isRaspberryPi then
        "pi"
      else
        "default"
    );
}
