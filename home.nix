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
    environment = null;  # Auto-detect (override with "ci"/"pi"/"wsl2"/"macos"/"default")

    # Deployment options (Phase 1: test environment variables and submodules only)
    deployEntryPoints = false;  # Deploy ~/.gitconfig, ~/.zshenv, etc.
    deployXdgConfig = false;    # Deploy ~/.config/{zsh,nvim,git,tmux,mise,etc.}
    deploySsh = false;          # Deploy ~/.ssh/config
    deployBash = false;         # Deploy ~/.bashrc, ~/.bash_profile
    deployAwsume = false;       # Deploy ~/.awsume/config.yaml
    initSubmodules = true;      # Initialize Git submodules (tmux plugins)
  };

  # This value determines the Home Manager release that your configuration is compatible with.
  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "24.11";
}
