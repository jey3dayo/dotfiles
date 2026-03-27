# Home Manager configuration for dotfiles
{
  pkgs,
  inputs,
  username,
  homeDirectory,
  ...
}:

let
  agentSkills = import ./nix/agent-skills.nix;
in
{
  # Basic home-manager settings
  home = {
    inherit username homeDirectory;

    # Fundamental packages (if needed)
    packages = with pkgs; [
      rsync # Required for copy-tree deployment
      btop
    ];

    # This value determines the Home Manager release that your configuration is compatible with.
    # You should not change this value, even if you update Home Manager.
    stateVersion = "24.11";
  };

  # Tools are installed via mise; Home Manager focuses on config distribution.

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    # Enable dotfiles module
    dotfiles = {
      enable = true;
      repoPath = ./.; # dotfiles repository root
      repoWorktreePath = null; # Auto-detect from repoPath or fallback paths
      environment = null; # Auto-detect (override with "ci"/"pi"/"default")

      # Deployment options (Phase 2: enable file deployment)
      # NOTE: ~/.config is managed directly by git checkout, not by Nix/Home Manager
      deployEntryPoints = true; # Deploy ~/.gitconfig, ~/.zshenv, etc.
      deploySsh = true; # Deploy ~/.ssh/config
      deployBash = true; # Deploy ~/.bashrc, ~/.bash_profile
      deployAwsume = true; # Deploy ~/.awsume/config.yaml
      initSubmodules = true; # Initialize Git submodules (tmux plugins)
    };

    # Agent skills are managed inside this repo (migrated from ~/.agents)
    agent-skills = {
      enable = true;

      # Single source of truth for internal skills/commands
      distributionsPath = ./agents/src;

      sources = import ./nix/sources.nix {
        inherit inputs agentSkills;
      };

      skills.enable = agentSkills.selection.enable or null;

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
  };
}
