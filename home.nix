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

  # Tools are installed via mise; Home Manager focuses on config distribution.

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable dotfiles module
  programs.dotfiles = {
    enable = true;
    repoPath = ./.;  # dotfiles repository root
    repoWorktreePath = null;  # Auto-detect from repoPath or fallback paths
    environment = null;  # Auto-detect (override with "ci"/"pi"/"wsl2"/"macos"/"default")

    # Deployment options (Phase 2: enable file deployment)
    # NOTE: ~/.config is managed directly by git checkout, not by Nix/Home Manager
    deployEntryPoints = true;   # Deploy ~/.gitconfig, ~/.zshenv, etc.
    deploySsh = true;           # Deploy ~/.ssh/config
    deployBash = true;          # Deploy ~/.bashrc, ~/.bash_profile
    deployAwsume = true;        # Deploy ~/.awsume/config.yaml
    initSubmodules = true;      # Initialize Git submodules (tmux plugins)
  };

  # Agent skills are managed inside this repo (migrated from ~/.agents)
  programs.agent-skills = {
    enable = true;

    # Single source of truth for internal skills/commands
    distributionsPath = ./agents/distributions/default;

    sources = import ./nix/sources.nix {
      inherit inputs;
      agentSkills = import ./nix/agent-skills.nix;
    };

    skills.enable =
      let selection = (import ./nix/agent-skills.nix).selection;
      in if selection ? enable then selection.enable else null;

    targets = import ./nix/targets.nix;

    configFiles = [
      {
        src = ./AGENTS.md;
        default = "AGENTS.md";
        rename = {
          claude = "CLAUDE.md";
          opencode = "CLAUDE.md";
          openclaw = "CLAUDE.md";
        };
      }
    ];
  };

  # This value determines the Home Manager release that your configuration is compatible with.
  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "24.11";
}
