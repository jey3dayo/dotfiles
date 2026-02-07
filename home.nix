# Home Manager configuration for dotfiles
{ config, pkgs, username, homeDirectory, ... }:

{
  # Basic home-manager settings
  home.username = username;
  home.homeDirectory = homeDirectory;

  # Fundamental packages (if needed)
  home.packages = with pkgs; [
    rsync  # Required for copy-tree deployment
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable dotfiles module
  programs.dotfiles = {
    enable = true;
    repoPath = ./.;  # dotfiles repository root
    repoWorktreePath = "${homeDirectory}/src/github.com/jey3dayo/dotfiles";  # Required when repoPath is in the Nix store
    environment = null;  # Auto-detect (override with "ci"/"pi"/"wsl2"/"macos"/"default")

    # Deployment options (Phase 2: enable file deployment)
    deployEntryPoints = true;   # Deploy ~/.gitconfig, ~/.zshenv, etc.
    deployXdgConfig = true;     # Deploy ~/.config/{zsh,nvim,git,tmux,mise,etc.}
    deploySsh = true;           # Deploy ~/.ssh/config
    deployBash = true;          # Deploy ~/.bashrc, ~/.bash_profile
    deployAwsume = true;        # Deploy ~/.awsume/config.yaml
    initSubmodules = true;      # Initialize Git submodules (tmux plugins)
  };

  # This value determines the Home Manager release that your configuration is compatible with.
  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "24.11";
}
