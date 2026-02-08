# Home Manager configuration for dotfiles
{ config, pkgs, lib, inputs, username, homeDirectory, ... }:

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
    repoWorktreePath = null;  # Auto-detect from repoPath or fallback paths
    environment = null;  # Auto-detect (override with "ci"/"pi"/"wsl2"/"macos"/"default")

    # Deployment options (Phase 2: enable file deployment)
    deployEntryPoints = true;   # Deploy ~/.gitconfig, ~/.zshenv, etc.
    deployXdgConfig = true;     # Deploy ~/.config/{zsh,nvim,git,tmux,mise,etc.}
    deploySsh = true;           # Deploy ~/.ssh/config
    deployBash = true;          # Deploy ~/.bashrc, ~/.bash_profile
    deployAwsume = true;        # Deploy ~/.awsume/config.yaml
    initSubmodules = true;      # Initialize Git submodules (tmux plugins)
  };

  # Agent skills are managed inside this repo (migrated from ~/.agents)
  programs.agent-skills = {
    enable = true;

    # Use skills-internal as local overrides to avoid external duplication conflicts
    localSkillsPath = ./agents/skills-internal;

    sources = import ./agents/nix/sources.nix { inherit inputs; };

    skills.enable =
      let selection = import ./agents/nix/selection.nix;
      in if selection ? enable then selection.enable else null;

    targets = import ./agents/nix/targets.nix;
  };

  # This value determines the Home Manager release that your configuration is compatible with.
  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "24.11";
}
