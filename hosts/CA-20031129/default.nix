{ inputs, ... }:

{
  imports = [
    ../../modules/darwin/touch-id-sudo.nix
  ];

  # Keep Nix itself managed by the existing installer/profile setup.
  nix.enable = false;

  # This flake only owns the PAM change; keep the existing system bashrc untouched.
  programs.bash.enable = false;

  # Required by nix-darwin for backwards compatibility.
  system.stateVersion = 6;

  # Record the source revision in the generated system metadata when available.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
