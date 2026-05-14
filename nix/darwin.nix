{ inputs, ... }:

{
  # Keep Nix itself managed by the existing installer/profile setup.
  nix.enable = false;

  # This flake only owns the PAM change; keep the existing system bashrc untouched.
  programs.bash.enable = false;

  # Enable Touch ID for sudo, including tmux/screen sessions via pam_reattach.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  environment.etc."pam.d/sudo_local".knownSha256Hashes = [
    # macOS default sudo_local template with Touch ID commented out.
    "6bcbb9339dbc848d7af6a2b69bf798d12e3184152d9b314828f71477a0660387"
  ];

  # Required by nix-darwin for backwards compatibility.
  system.stateVersion = 6;

  # Record the source revision in the generated system metadata when available.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
